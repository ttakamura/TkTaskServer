require 'pathname'

TK_ROOT_DIR = Pathname.new File.expand_path("..", __FILE__)
TK_ENV      = ENV['APP_ENV'] || 'development'

require File.expand_path("../lib/setting.rb", __FILE__)
require File.expand_path("../lib/db.rb", __FILE__)
require File.expand_path("../lib/dropbox.rb", __FILE__)
