# frozen_string_literal: true

# Helpers to represent pastes
module PastesHelper
  def represent(attachment)
    return padding(t(:no_attachment)) unless attachment
    return media(attachment) if media?(attachment)

    padding(link_to(attachment.filename, attachment.url))
  end

  def badge(text)
    tag.span(text, class: 'badge text-bg-info')
  end

  def extensions(attachment)
    marcel = Marcel::Magic.new(attachment.content_type).extensions
    mimemagic = MimeMagic.new(attachment.content_type).extensions
    (marcel + mimemagic).uniq
  end

  private

  def image(attachment)
    padding(image_tag(representation_url(attachment)))
  end

  def video(attachment)
    poster = representation_url(attachment) if attachment.representable?
    padding(video_tag(attachment.url, controls: true, poster:))
  end

  def audio(attachment)
    padding(audio_tag(attachment.url, controls: true))
  end

  def document(attachment)
    padding(render('shared/document_info', attachment:, representation: representation_url(attachment)))
  end

  def text(attachment)
    content = attachment.open(&:read).force_encoding('utf-8')
    tag.textarea content, disabled: true, id: 'paste_code',
                          class: 'form-control border-0 rounded-0 rounded-bottom',
                          'data-editor-target': 'textarea',
                          rows: content.lines.count
  end

  def text?(attachment)
    Marcel::Magic.new(attachment.content_type).text? || MimeMagic.new(attachment.content_type).text?
  end

  def media(attachment)
    return image(attachment) if attachment.image? && attachment.representable?
    return video(attachment) if attachment.video?
    return audio(attachment) if attachment.audio?
    return text(attachment) if text?(attachment)

    document(attachment) if attachment.representable?
  end

  def media?(attachment)
    attachment.representable? || attachment.image? || attachment.video? || attachment.audio? || text?(attachment)
  end

  def representation_url(attachment)
    representation = attachment.representation({})
    representation.processed.url
  end

  def padding(content)
    tag.div content, class: 'card-body d-flex justify-content-center position-relative'
  end
end
