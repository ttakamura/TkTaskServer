# -*- coding: utf-8 -*-
class Dropbox
  class RecordFields < Virtus::Attribute
    def coerce values
      res = {}
      values.each do |k, value|
        res[k.to_sym] = parse(value)
      end
      res
    end

    private
    def parse value
      return value.map{|v| parse(v) } if value.is_a?(Array)

      return value if value.is_a?(String) || value.is_a?(Numeric) || value.is_a?(TrueClass) || value.is_a?(FalseClass) || value.is_a?(NilClass)

      type, str_value = value.to_a.first
      case type
      when 'I'
        str_value.to_i
      when 'T'
        Time.at(str_value.to_i/1000.0)
      when 'B'
        str_value # base64 encoded
      else
        "Unknown type of RecordFields: #{value}"
      end
    end
  end

  class Record < Resource
    extend Dropbox::ApiMapper::Client
    index_api url: '/1/datastores/get_snapshot', params: ->{ {handle: parent.handle} },
                                                 parser: ->(res){ res.body['rows']   }
    attribute :tid,   String
    attribute :rowid, String
    attribute :data,  RecordFields

    def method_missing key, *args
      data[key]
    end
  end

  class RecordOperation < Record
  end

  class RecordChanges < Virtus::Attribute
    class Create < Resource
      attribute :record, Record
    end

    class Update < Resource
      attribute :record, RecordOperation
    end

    class Delete < Resource
      attribute :record
    end

    def coerce values
      values.map do |value|
        type, tid, rid, data = value
        case type
        when 'I'
          Create.new record: Record.new(tid: tid, rowid: rid, data: data)
        when 'U'
          Update.new record: RecordOperation.new(tid: tid, rowid: rid, data: data)
        when 'D'
          Delete.new record: Record.new(tid: tid, rowid: rid, data: data)
        else
          raise 'Unknown type of RecordChanges: #{value.first}'
        end
      end
    end
  end

  class Delta < Resource
    attribute :rev,     Integer
    attribute :changes, RecordChanges
    attribute :nonce,   String, default: '' # base64 encoded
  end

  class DataStore < Resource
    extend Dropbox::ApiMapper::Client
    index_api url: '/1/datastores/list_datastores', parser: ->(res){ res.body['datastores'] }

    attribute :dsid,    String
    attribute :handle,  String
    attribute :rev,     Integer
    has_many  :records, Record
  end
end
