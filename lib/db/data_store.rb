class DB::DataStore
  attr_reader :deltas, :records

  def initialize remote_data_store, delta_raw_db, record_raw_db
    @records = DB::Record.new record_raw_db, remote_data_store.records
    @deltas  = DB::Delta.new  delta_raw_db, records, remote_data_store.deltas
    @sync    = remote_data_store.syncs.new deltas
  end

  def sync!
    @sync.sync!
  end
end
