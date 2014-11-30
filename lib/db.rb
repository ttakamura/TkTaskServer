require 'leveldb'

class DB
  def self.open name=:default, *args
    remote_db = Dropbox::DataStore[name]
    local_db  = DB::DataStore.new remote_db, DB::LevelDB.new(path: "#{name}_deltas"), DB::LevelDB.new(path: "#{name}_records")
    [remote_db, local_db]
  end
end

require File.expand_path(File.dirname(__FILE__)) + '/db/base.rb'
require File.expand_path(File.dirname(__FILE__)) + '/db/leveldb.rb'
require File.expand_path(File.dirname(__FILE__)) + '/db/delta.rb'
require File.expand_path(File.dirname(__FILE__)) + '/db/record.rb'
require File.expand_path(File.dirname(__FILE__)) + '/db/data_store.rb'
