# -*- coding: utf-8 -*-
class Dropbox
  class RecordResource < Resource
    index_api url: '/1/datastores/get_snapshot', params: ->{ {handle: parent.handle} },
                                                 parser: ->(res){ res.body['rows']   }
    attribute :tid,   String
    attribute :rowid, String
    attribute :data,  Hash

    def method_missing key, *args
      parse_field data[key.to_s]
    end

    private
    def parse_field value
      return value unless value.is_a?(Hash)

      type, str_value = value.to_a.first
      case type
      when 'I'
        str_value.to_i
      when 'T'
        Time.at(str_value.to_i/1000.0)
      when 'B'
        str_value # base64 encoded
      else
        nil
      end
    end
  end

  class DataStoreResource < Resource
    index_api url: '/1/datastores/list_datastores', parser: ->(res){ res.body['datastores'] }

    attribute :dsid,    String
    attribute :handle,  String
    attribute :rev,     Integer
    has_many  :records, RecordResource
  end
end
