# -*- coding: utf-8 -*-
class Dropbox
  class Delta < Resource
    attribute :rev,     Integer,     default: ->(delta, attr){ delta.class.data_store.rev }
    attribute :changes, RecordChanges
    attribute :nonce,   String,      required: false         # base64 encoded

    def self.all
      Dropbox::Api.get_deltas(data_store.handle, 0)[:deltas]
    end

    def save!
      self.rev = Dropbox::Api.put_delta(self.class.data_store.handle, self)[:rev]
    end

    def to_json
      changes.map do |change|
        change.serialize
      end.to_json
    end
  end
end
