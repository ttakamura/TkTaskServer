class Dropbox
  class Resource
    include Virtus.model

    class << self
      def index_api options
        @index_api = options
      end

      def fetch_all
        resources = @index_api[:parser].call Dropbox.connection.get(@index_api[:url])
        resources = resources.map{|x| self.new x } if resources.first.is_a?(Hash)
        resources
      end

      def attribute key, type
        super(key, type)
      end
    end
  end
end
