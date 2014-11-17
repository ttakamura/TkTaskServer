# -*- coding: utf-8 -*-
class Dropbox
  class Record < Resource
    include Dropbox::FieldSerializer
    attribute :tid,   String
    attribute :rowid, String,      required: false
    attribute :data,  RecordFields

    def self.all
      Dropbox::Api.get_snapshot(data_store.handle)[:rows]
    end

    # TODO: Check new-record? or not
    # TODO: Use UUID?
    def save!
      change = unless self.rowid
                 self.rowid = Digest::SHA1.hexdigest(rand.to_s)
                 Dropbox::RecordChanges::Create.new(record: self)
               else
                 Dropbox::RecordChanges::Update.new(record: self)
               end
      delta = self.class.data_store.deltas.new changes: [change]
      delta.save!
    end

    def method_missing key, *args
      if v = data[key]
        v
      else
        super
      end
    end

    def serialize_data
      result = {}
      data.each do |k, v|
        result[k.to_s] = serialize_value(v)
      end
      result
    end
  end

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

    def serialize_changes
      changes.map do |change|
        change.serialize
      end.to_json
    end
  end

  class RecordOperation < Resource
    attribute :tid,   String
    attribute :rowid, String
    attribute :data,  RecordFieldOperations
  end
end
