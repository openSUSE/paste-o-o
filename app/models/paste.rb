# frozen_string_literal: true

# The primary application model for storing pastes
class Paste < ApplicationRecord
  self.implicit_order_column = 'created_at'

  PERIODS = [[I18n.t(:months, count: 3), 3.months],
             [I18n.t(:months, count: 1), 1.month],
             [I18n.t(:weeks, count: 2), 2.weeks],
             [I18n.t(:weeks, count: 1), 1.week],
             [I18n.t(:days, count: 3), 3.days],
             [I18n.t(:days, count: 1), 1.day],
             [I18n.t(:hours, count: 12), 12.hours],
             [I18n.t(:hours, count: 6), 6.hours],
             [I18n.t(:hours, count: 1), 1.hour],
             [I18n.t(:minutes, count: 30), 30.minutes]].freeze

  has_one_attached :content
  belongs_to :user, optional: true
  belongs_to :marked_by, class_name: 'User', optional: true

  enum :marked_kind, %w[unclassified ham spam]

  attribute :author, default: -> { Paste.default_author }
  attribute :remove_at, default: -> { Time.zone.now + 7.days.seconds }

  before_save :train_classifier
  before_save :delete_spam
  before_save :check_terms
  before_create :create_permalink
  after_save :enqueue_removal

  validates :content, presence: true
  validate :content_size
  validate :remove_at_max

  # Avoiding the case of showing anonymous users' private pastes to anonymous users
  scope :by_author, ->(user) { where(user:).where.not(user: nil) }

  def to_param
    permalink
  end

  def code=(value)
    return if value.empty?

    io = StringIO.new(value)
    default_mime = Marcel::Magic.new('text/plain')
    mime = Marcel::Magic.by_magic(value) || default_mime
    filename = "#{SecureRandom.hex(16)}.#{mime.extensions.first}"
    blob = ActiveStorage::Blob.create_and_upload!(io:, filename:)
    content.attach(blob)
  end

  def code
    return '' unless content&.attachment

    content.attachment.open(&:read).force_encoding('utf-8')
  rescue ActiveStorage::FileNotFoundError
    return ''
  end

  def content_size
    errors.add(:content, I18n.t(:too_large)) if content.blob&.byte_size&.>(2.megabytes)
  end

  def remove_after
    return 0 unless remove_at

    remove_at - Time.zone.now
  end

  def remove_after=(value)
    self.remove_at = Time.zone.now + value.to_i
  end

  def auth_key=(key)
    auth = Auth.find_by(key:)
    self.user = auth.user if auth&.user&.valid?
  end

  def self.default_author
    animal = Faker::Creature::Animal.name.titlecase
    adjective = Faker::Adjective.positive.titlecase
    I18n.t(:adjective_animal, adjective:, animal:)
  end

  def remove_at_max
    largest_period = Paste::PERIODS[0][1]
    errors.add(:remove_after, t(:too_long, time: largest_period.inspect)) if remove_after >= largest_period.seconds
  end

  private

  def create_permalink
    self.permalink = SecureRandom.hex(6)
  end

  def enqueue_removal
    PastesCleanupJob.set(wait_until: remove_at).perform_later(self)
  end

  def train_classifier
    return unless saved_change_to_marked_kind? || saved_change_to_marked_by_id?
    return if marked_kind == 'unclassified'
    return if marked_by.nil?

    classifier = Rails.application.config.classifier
    classifier.train marked_kind, code
  end

  def delete_spam
    destroy! if marked_by.present? && marked_kind == 'spam'
  end

  def check_terms
    Term.all.each do |term|
      content = self.send(term.subject)
      next unless content.include?(term.content)

      self.marked_kind = 'spam'
    end
  end
end
