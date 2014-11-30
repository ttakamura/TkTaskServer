class Dropbox
  class Api
    Base = '/1/datastores'

    class << self
      def connection
        Dropbox.connection
      end

      def list_datastores
        res = connection.get("#{Base}/list_datastores")
        ds  = res.body['datastores'].map do |v|
          Dropbox::DataStore.new v
        end
        {datastores: ds}
      end

      def get_snapshot handle
        res  = connection.get("#{Base}/get_snapshot", handle: handle)
        rows = res.body['rows'].map do |v|
          Dropbox::Record.new v
        end
        {rev: res.body['rev'].to_i, rows: rows}
      end

      def get_deltas handle, rev
        res = connection.get("#{Base}/get_deltas", handle: handle, rev: rev)
        dts = (res.body['deltas'] || []).map do |v|
          Dropbox::Delta.new v
        end
        {deltas: dts}
      end

      def put_delta handle, delta
        res = connection.post("#{Base}/put_delta", handle: handle, rev: delta.rev, changes: delta.changes_to_json)
        {rev: res.body['rev'].to_i}
      end
    end
  end
end
