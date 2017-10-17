# Enable whitelist auth mode so that MiniProfiler#authorize_request has some effect.
Rack::MiniProfiler.config.authorization_mode = :whitelist