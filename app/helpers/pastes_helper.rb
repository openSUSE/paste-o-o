# frozen_string_literal: true

# Helpers to represent pastes
module PastesHelper
  def represent(attachment)
    return padding(t(:no_attachment)) unless attachment
    return image(attachment) if attachment.representable?
    return text(attachment) if Marcel::Magic.new(attachment.content_type).text?

    padding(link_to(attachment.filename, attachment.url))
  end

  def badge(text)
    tag.span(text, class: 'badge text-bg-info')
  end

  private

  def image(attachment)
    representation = attachment.representation({})
    padding(image_tag(representation.processed.url))
  end

  def text(attachment)
    tag.textarea attachment.open(&:read).force_encoding('utf-8'), disabled: true, id: 'paste_code',
                                                                  class: 'form-control',
                                                                  'data-editor-target': 'textarea'
  end

  def padding(content)
    tag.div(content, class: 'card-body d-flex justify-content-center')
  end
end
