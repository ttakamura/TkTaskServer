# -*- coding: utf-8 -*-
class Dropbox
  module FieldSerializer
    def serialize_value ruby_value
      case ruby_value
      when Integer
        {'I' => ruby_value.to_s}
      when Time
        {'T' => (ruby_value.to_i*1000).to_s}
      else
        ruby_value
      end
    end
  end

  module FieldParser
    def parse_value value
      return value.map{|v| parse_value(v) } if value.is_a?(Array)

      return value unless value.is_a?(Hash)

      # <wrapped_int>       ::= {"I": <str>}  # decimal representation of a signed 64-bit int
      # <wrapped_special>   ::= {"N": "nan"}
      #                       | {"N": "+inf"}
      #                       | {"N": "-inf"}
      # <wrapped_timestamp> ::= {"T" : <str>}  # decimal representation of a signed 64-bit int
      # <wrapped_bytes>     ::= {"B" : <dbase64>}  # dbase64-encoded bytes
      type, str_value = value.to_a.first
      case type
      when 'I'
        str_value.to_i
      when 'T'
        Time.at(str_value.to_i/1000.0)
      when 'B'
        str_value # base64 encoded
      else
        raise "Unknown type of RecordFields: #{value}"
      end
    end
  end

  class RecordFields < Virtus::Attribute
    include FieldParser

    def coerce values
      res = {}
      values.each do |k, value|
        res[k.to_sym] = parse_value(value)
      end
      res
    end
  end

  class RecordFieldOperations < RecordFields
    class Put < Resource
      include Dropbox::FieldSerializer
      attribute :value, Object

      def serialize
        ['P', serialize_value(value)]
      end
    end

    class Delete < Resource
      def serialize
        ['D']
      end
    end

    def self.serialize record
      operations = {}
      record.data.map do |k, v|
        operations[k] = ['P', v]
      end
      operations
    end

    private
    def parse_value fieldop
      case fieldop.first
      when 'P'
        Put.new value: super(fieldop.last)
      when 'D'
        Delete.new
      when 'LC'
        # <fieldop>           ::= ["P", <value>]  # PUT
        #                       | ["D"]  # DELETE
        #                       | ["LC"] # LIST_CREATE
        #                       | ["LP", <index>, <atom>]  # LIST_PUT
        #                       | ["LI", <index>, <atom>]  # LIST_INSERT
        #                       | ["LD", <index>]  # LIST_DELETE
        #                       | ["LM", <index>, <index>]  # LIST_MOVE
        raise 'not implemented'
      when 'LP'
        raise 'not implemented'
      when 'LI'
        raise 'not implemented'
      when 'LD'
        raise 'not implemented'
      when 'LM'
        raise 'not implemented'
      else
        raise "Unknown type of RecordFieldOperations: #{fieldop}"
      end
    end
  end

  class RecordChanges < Virtus::Attribute
    class Create < Resource
      attribute :record, Record

      def serialize
        ['I', record.tid, record.rowid, record.serialize_data]
      end
    end

    class Update < Resource
      attribute :record, RecordOperation

      def serialize
        ['U', record.tid, record.rowid, record.serialize_data]
      end
    end

    class Delete < Resource
      attribute :record

      def serialize
        ['D', record.tid, record.rowid]
      end
    end

    def coerce values
      values.map do |value|
        if value.is_a?(Create) || value.is_a?(Update) || value.is_a?(Delete)
          value
        else
          type, tid, rid, data = value
          case type
          when 'I'
            Create.new record: Record.new(tid: tid, rowid: rid, data: data)
          when 'U'
            Update.new record: RecordOperation.new(tid: tid, rowid: rid, data: data)
          when 'D'
            Delete.new record: Record.new(tid: tid, rowid: rid, data: data)
          else
            raise "Unknown type of RecordChanges: #{value.first}"
          end
        end
      end
    end
  end
end
