# -*- coding: utf-8 -*-
class Dropbox
  class Delta < Resource
    attribute :rev,     Integer,     default: ->(delta, attr){ delta.class.data_store.rev }
    attribute :changes, RecordChanges
    attribute :nonce,   String,      required: false         # base64 encoded

    def self.all rev=0
      Dropbox::Api.get_deltas(data_store.handle, rev)[:deltas]
    end

    def self.bundle records
      self.new changes: records.map(&:to_change)
    end

    def save!
      self.rev = self.class.data_store.rev = Dropbox::Api.put_delta(self.class.data_store.handle, self)[:rev]
    end

    def changes_to_json
      serialize[:changes].to_json
    end

    def serialize
      hash = attributes
      hash[:changes] = changes.map{ |change| change.serialize }
      hash
    end
  end
end
