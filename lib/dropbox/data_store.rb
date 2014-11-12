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

    def create!
      self.rowid ||= Digest::SHA1.hexdigest(rand.to_s)  # Use UUID?
      change = Dropbox::RecordChanges::Create.new(record: self)
      delta  = self.class.data_store.deltas.new changes: [change]
      delta.save!
    end

    def method_missing key, *args
      data[key]
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

  class DataStore < Resource
    attribute :dsid,    String
    attribute :handle,  String
    attribute :rev,     Integer

    def self.all
      Dropbox::Api.list_datastores[:datastores]
    end

    def records
      data_store = self
      @records ||= Class.new(Record) do
        define_singleton_method(:data_store) { data_store }
      end
    end

    def deltas
      data_store = self
      @deltas ||= Class.new(Delta) do
        define_singleton_method(:data_store) { data_store }
      end
    end
  end

  class RecordOperation < Resource
    attribute :tid,   String
    attribute :rowid, String
    attribute :data,  RecordFieldOperations
  end
end
