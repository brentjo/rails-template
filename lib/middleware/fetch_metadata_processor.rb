module Middleware
  class FetchMetadataProcessor

    SITE_HEADER = "HTTP_SEC_FETCH_SITE".freeze
    MODE_HEADER = "HTTP_SEC_FETCH_MODE".freeze
    DEST_HEADER = "HTTP_SEC_FETCH_DEST".freeze

    ALLOWED_SEC_FETCH_SITES = ["same-origin", "none"].freeze
    DISALLOWED_SEC_FETCH_DESTS = ["object", "embed"].freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      req = Rack::Request.new(env)

      # Browsers lacking support should pass right through
      if !req.get_header(SITE_HEADER)
        return @app.call(env)
      end

      # Allow same-site and browser-initiated requests
      if ALLOWED_SEC_FETCH_SITES.include?(req.get_header(SITE_HEADER))
        return @app.call(env)
      end

      # Allow simple top-level navigations except <object> and <embed>
      if req.get_header(MODE_HEADER) == "navigate" && req.request_method == "GET" && !DISALLOWED_SEC_FETCH_DESTS.include?(req.get_header(DEST_HEADER))
        return @app.call(env)
      end

      [400, {"Content-Type" => "text/plain"}, ["Invalid request"]]
    end

  end
end
