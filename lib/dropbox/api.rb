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

      def delete_datastore handle
        res = connection.post("#{Base}/delete_datastore", handle: handle)
        {ok: res.body['ok']}
      end

      def get_or_create_datastore dsid
        res = connection.post("#{Base}/get_or_create_datastore", dsid: dsid)
        {rev: res.body['rev'], handle: res.body['handle'], created: res.body['created']}
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
        payload = {handle: handle, rev: delta.rev, changes: delta.changes_to_json}

        puts "Sending delta... #{delta}"
        puts payload

        res = connection.post("#{Base}/put_delta", payload)

        puts res.body
        raise res.body unless res.body['rev']

        {rev: res.body['rev'].to_i}
      end
    end
  end
end
