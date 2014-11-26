class Dropbox
  class Resource
    include Virtus.model(strict: true)

    def self.unpack str
      self.new JSON.parse(str)
    end

    def pack
      serialize.to_json
    end
  end
end
