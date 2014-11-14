# -*- coding: utf-8 -*-
class Dropbox
  class Connection
    def initialize access_token=nil
      @access_token = access_token
    end

    def get *args
      check_error connection.get(*args)
    end

    def post *args
      check_error connection.post(*args)
    end

    def put *args
      check_error connection.put(*args)
    end

    def delete *args
      check_error connection.delete(*args)
    end

    def check_error res
      raise "FatalError: #{res.status} - #{res.body}" if res.status.to_i >= 400
      res
    end

    def connection
      @connection ||= new_connection(api_logging: (Dropbox::API_LOGGING == 'true'))
    end

    def new_connection options={}
      Faraday.new(url: END_POINT) do |conn|
        conn.request  :url_encoded
        conn.request  :dropbox_api_key_auth, key: APP_KEY, secret: APP_SECRET     if options[:api_key_auth]
        conn.request  :dropbox_bearer_auth,  token: access_token              unless options[:api_key_auth]
        conn.response :logger                                                     if options[:api_logging]
        conn.response :json, :content_type => /(json|javascript)/
        conn.adapter  Faraday.default_adapter
      end
    end

    def access_token
      @access_token ||= get_access_token
    end

    def get_access_token
      url = "https://www.dropbox.com/1/oauth2/authorize?client_id=#{APP_KEY}&response_type=code"
      puts "Please open this url on browser: #{url}"
      system("open '#{url}'")
      auth_code = gets.chomp
      conn   = new_connection(api_key_auth: true)
      params = {code: auth_code, grant_type: 'authorization_code'}
      res    = conn.post('/1/oauth2/token', params)
      res.body['access_token']
    end
  end

  # ----- middleware --------------------------------------------------------
  class ApiKeyAuth < Faraday::Middleware
    def initialize app=nil, options={}
      super(app)
      @options = options
    end

    def call env
      app_key    = @options[:key]
      app_secret = @options[:secret]
      env[:request_headers]['Authorization'] = "Basic " + Base64.encode64("#{app_key}:#{app_secret}").chomp
      @app.call env
    end
  end

  class BearerAuth < Faraday::Middleware
    def initialize app=nil, options={}
      super(app)
      @options = options
    end

    def call env
      access_token = @options[:token]
      env[:request_headers]['Authorization'] = "Bearer #{access_token}"
      @app.call env
    end
  end

  Faraday::Request.register_middleware dropbox_api_key_auth: ->{ ApiKeyAuth }
  Faraday::Request.register_middleware dropbox_bearer_auth:  ->{ BearerAuth }
end
