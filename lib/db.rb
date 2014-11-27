require 'leveldb'

class DB
  def self.open *args
    ::DB::LevelDB.new(*args)
  end
end

require File.expand_path(File.dirname(__FILE__)) + '/db/base.rb'
require File.expand_path(File.dirname(__FILE__)) + '/db/leveldb.rb'
require File.expand_path(File.dirname(__FILE__)) + '/db/delta.rb'
