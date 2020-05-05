module Consul
  class Application < Rails::Application
    config.i18n.default_locale = :nl
    config.i18n.available_locales = ["nl"]
    config.i18n.available_locales = ["en", "es", "fr", "gl", "it", "nl", "pt-BR"] if Rails.env.test?
  end
end
