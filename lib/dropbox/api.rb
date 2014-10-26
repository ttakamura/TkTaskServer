class Dropbox
  class ApiMapper
    module Client
      def index_api options
        define_singleton_method(:index_api_mapper) do
          ApiMapper.new(self, options)
        end
      end

      def fetch_all
        index_api_mapper.fetch_all
      end
    end
    attr_reader :options

    def initialize model, options={}
      @model   = model
      @options = options
    end

    def fetch_all
      response  = Dropbox.connection.get(url, params)
      resources = parse response
      resources = resources.map{|x| @model.new x } if resources.first.is_a?(Hash)
      resources
    end

    def parse response
      options[:parser].call response
    end

    def url
      options[:url]
    end

    def params
      case options[:params]
      when Hash
        options[:params]
      when Proc
        @model.instance_exec(&options[:params])
      else
        nil
      end
    end
  end
end
