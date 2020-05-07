module Consul
  class Application < Rails::Application
    unless Rails.env.test?
      config.i18n.default_locale = :nl
      config.i18n.available_locales = ["nl"]
    end
  end
end
