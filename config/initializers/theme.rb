# frozen_string_literal: true

if (theme = Rails.configuration.site['theme'])
  path = Rails.root.join('app/themes', theme)
  ActionController::Base.prepend_view_path path.join('views')
  Rails.application.config.assets.paths.unshift path.join('assets/images'), path.join('assets/javascripts'),
                                                path.join('assets/stylesheets')
  Sprockets.prepend_path(path.join('assets/config'))
  Sprockets.prepend_path(path.join('assets/stylesheets'))
  Sprockets.prepend_path(path.join('assets/javascripts'))
  Sprockets.prepend_path(path.join('assets/images'))
end
