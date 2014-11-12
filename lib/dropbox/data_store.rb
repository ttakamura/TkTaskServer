# -*- coding: utf-8 -*-
class Dropbox
  class Record < Resource
    include Dropbox::FieldSerializer

    extend Dropbox::ApiMapper::Client
    index_api url: '/1/datastores/get_snapshot', params: ->{ {handle: parent.handle} },
                                                 parser: ->(res){ res.body['rows']   }

    attribute :tid,   String
    attribute :rowid, String
    attribute :data,  RecordFields

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

  class RecordOperation < Resource
    attribute :tid,   String
    attribute :rowid, String
    attribute :data,  RecordFieldOperations
  end

  class Delta < Resource
    extend Dropbox::ApiMapper::Client
    index_api url: '/1/datastores/get_deltas', params: ->{ {handle: parent.handle, rev: 0} },
                                               parser: ->(res){ res.body['deltas']         }

    create_api url: '/1/datastores/put_delta', params: ->(delta){ {handle: parent.handle, rev: delta.rev, changes: delta.serialize_changes} }

    attribute :rev,     Integer
    attribute :changes, RecordChanges
    attribute :nonce,   String, default: '' # base64 encoded

    def serialize_changes
      changes.map do |change|
        change.serialize
      end.to_json
    end
  end

  class DataStore < Resource
    extend Dropbox::ApiMapper::Client
    index_api url: '/1/datastores/list_datastores', parser: ->(res){ res.body['datastores'] }

    attribute :dsid,    String
    attribute :handle,  String
    attribute :rev,     Integer
    has_many  :records, Record
    has_many  :deltas,  Delta
  end
end
