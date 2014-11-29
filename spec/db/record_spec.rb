require 'spec_helper'

describe DB::Record do
  let(:db)     { DB::Record.new DB::Hash.new }
  let(:record) { Dropbox::Record.new(tid: 'test', rowid: '123', data: {name: 'tom', age: 22}) }

  before do
    db['123'] = record
  end

  subject { db }

  describe '[]' do
    subject { db['123'] }

    it { should == record }
  end
end
