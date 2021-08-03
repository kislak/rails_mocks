# frozen_string_literal: true

module RailsMocks
  class Middleware
    HEADER_NAME = "HTTP_RAILS_MOCKS"

    def initialize(app)
      @app = app
    end

    def call(req)
      return @app.call(req) if stubs(req).blank?

      status, headers, response = nil
      RSpec::Mocks.with_temporary_scope do
        RSpec::Mocks::Syntax.enable_expect(self.class)

        parsed_stubs(req).each do |stub|
          if stub.file
            instance_eval(File.read(stub.file))
            next
          end

          allow(stub.allow).to(stub.receiver)
        end
        status, headers, response = @app.call(req)
      end
      [status, headers, response]
    end

    private

    def parsed_stubs(req)
      JSON.parse(stubs(req), symbolize_names: true).map do |stub|
        RailsMocks::Stub.new(stub)
      end
    end

    def stubs(req)
      req[HEADER_NAME]
    end
  end
end
