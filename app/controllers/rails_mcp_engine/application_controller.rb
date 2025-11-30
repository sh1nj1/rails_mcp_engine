module RailsMcpEngine
  class ApplicationController < ::ApplicationController
    include RailsMcpEngine::Engine.routes.url_helpers
  end
end
