# frozen_string_literal: true

# Support for the old api endpoints
class OldapiController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  # POST /
  def create
    @paste = Paste.new(oldapi_params)

    if @paste.save
      redirect_to "/#{@paste.permalink}", notice: t(:paste_created)
    else
      redirect_to root_path, alert: t(:paste_failed)
    end
  end

  def redirect
    if (@paste = Paste.find_by(permalink: params[:permalink]))
      redirect_to paste_url(@paste)
    else
      redirect_to "https://susepaste.org/#{params[:permalink]}", allow_other_host: true
    end
  end

  private

  def oldapi_params
    params.permit(:code, :title, :expire, :name, :file, :submit, :lang, :api_key)
    opts = params.slice(:code, :title)
    opts.merge!(ensure_presence({ author: params[:name], content: params[:file],
                                  remove_after: remove_after(params[:expire]) }))
    # It's probably better to ignore the old keys
    # opts[:auth_key] = params[:api_key]
    opts.permit(:code, :title, :remove_after, :author, :content)
  end

  def remove_after(expire)
    return expire.to_i.days.seconds.to_i if expire

    60.days.seconds.to_i
  end

  def ensure_presence(params)
    params.each_with_object({}) do |(key, value), object|
      object[key] = value if value
    end
  end
end
