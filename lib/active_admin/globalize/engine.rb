module ActiveAdmin
  module Globalize
    class Engine < ::Rails::Engine
      initializer "Active Admin precompile hook", group: :all do |app|
        app.config.assets.precompile += [
          "active_admin/active_admin_globalize.css",
          "active_admin/active_admin_globalize.js"
        ]
      end
    end
  end
end
