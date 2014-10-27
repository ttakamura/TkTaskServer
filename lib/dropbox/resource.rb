class Dropbox
  class Resource
    class << self
      def attribute key, type
        super(key, type)
      end

      def has_many key, klass
        define_method(key) do
          has_many_resources[key] ||= begin
            parent = self
            Class.new(klass) do
              define_singleton_method(:parent) do
                parent
              end
            end
          end
        end
      end
    end

    include Virtus.model(strict: true)

    def has_many_resources
      @has_many_resources ||= {}
    end
  end
end
