require 'pathname'

TK_ROOT_DIR = Pathname.new File.expand_path("..", __FILE__)
TK_ENV      = ENV['APP_ENV'] || 'development'

require File.expand_path("../lib/setting.rb", __FILE__)
require File.expand_path("../lib/db.rb", __FILE__)
require File.expand_path("../lib/dropbox.rb", __FILE__)

$remote_db = Dropbox::DataStore.default
$local_db  = DB::DataStore.new $remote_db, DB::LevelDB.new(path: 'deltas'), DB::LevelDB.new(path: 'records')
