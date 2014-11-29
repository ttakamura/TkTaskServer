require 'spec_helper'

describe DB::LevelDB do
  let(:db) { DB::LevelDB.new }

  it_behaves_like 'the sub-class of DBs'
end
