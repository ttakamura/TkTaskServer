require 'spec_helper'

describe DB::Base do
  let(:db) { DB::Hash.new }

  it_behaves_like 'the sub-class of DBs'
end
