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
    def to_delta
      change = unless self.rowid
                 self.rowid = Digest::SHA1.hexdigest(rand.to_s)
                 Dropbox::RecordChanges::Create.new(record: self)
               else
                 Dropbox::RecordChanges::Update.new(record: RecordOperation.from_record(self))
               end
      self.class.data_store.deltas.new changes: [change]
    end

    def save!
      to_delta.save!
    end

    def method_missing key, *args
      if match = key.to_s.match(/^(.+)=$/)
        data[match[1].to_sym] = args.first
      elsif v = data[key]
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

    def serialize
      attributes
    end
  end

  class RecordOperation < Resource
    attribute :tid,   String
    attribute :rowid, String
    attribute :data,  RecordFieldOperations

    def self.from_record record
      self.new tid: record.tid, rowid: record.rowid, data: RecordFieldOperations.serialize(record)
    end

    def serialize_data
      result = {}
      data.each do |k, v|
        result[k.to_s] = v.serialize
      end
      result
    end
  end
end
