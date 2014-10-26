class Dropbox
  class RecordResource < Resource
    index_api url: '/1/datastores/get_snapshot', params: ->{ {handle: parent.handle} },
                                                 parser: ->(res){ res.body['rows']   }
    attribute :tid,   String
    attribute :rowid, String
    attribute :data,  Hash
    #    {
    #        "tid": "tasks",
    #        "data": {
    #            "taskname": "do laundry",
    #            "completed": false
    #        },
    #        "rowid": "myrecord"
    #    }
  end

  class DataStoreResource < Resource
    index_api url: '/1/datastores/list_datastores', parser: ->(res){ res.body['datastores'] }

    attribute :dsid,    String
    attribute :handle,  String
    attribute :rev,     Integer
    has_many  :records, RecordResource
  end
end
