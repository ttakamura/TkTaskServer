class DB::LevelDB < DB::Base
  def open
    ::LevelDB::DB.new options[:path] ? (Setting.db_path + '/' + options[:path])
                                     : Setting.db_path
  end
end
