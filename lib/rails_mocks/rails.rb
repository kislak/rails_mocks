# frozen_string_literal: true

module RailsMocks
  class Railtie < Rails::Railtie
    initializer "rails_mocks.configure_rails_initialization" do
      insert_middleware
    end

    def insert_middleware
      app.middleware.use RailsMocks::Middleware
    end

    def app
      Rails.application
    end
  end
end
