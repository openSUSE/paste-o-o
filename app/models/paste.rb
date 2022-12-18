# frozen_string_literal: true

# The primary application model for storing pastes
class Paste < ApplicationRecord
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

  attribute :author, default: -> { Paste.default_author }
  attribute :remove_at, default: -> { Time.zone.now + 7.days.seconds }

  before_create :create_permalink
  after_save :enqueue_removal

  validates :content, presence: true
  validate :content_size
  validate :remove_at_max

  # Avoiding the case of showing anonymous users' private pastes to anonymous users
  scope :by_author, ->(user) { where(user:).where.not(user: nil) }
  scope :all_public, -> { where(private: false) }
  # All the pastes that a logged in or non logged in user should be able to see
  scope :for_user, ->(current_user) { all_public.or(Paste.by_author(current_user)) }

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

  def code = ''

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
end
