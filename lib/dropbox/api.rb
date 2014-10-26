class Dropbox
  class DataStoreResource < Resource
    index_api url: '/1/datastores/list_datastores', parser: ->(res){ res.body['datastores'] }

    attribute :dsid,   String
    attribute :handle, String
    attribute :rev,    Integer
  end
end
