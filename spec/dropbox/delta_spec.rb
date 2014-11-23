require 'spec_helper'

describe Dropbox::Delta do
  let(:data_store) { Dropbox::DataStore.new handle: 'my_handle', dsid: 'default', rev: 10 }
  let(:record)     { data_store.records.new tid: 'table1', rowid: '123456', data: data }
  let(:data)       { {name: 'hello', age: 20} }
  let(:delta)      { record.to_delta }

  subject { delta }

  its(:rev) { should == 10 }

  describe '#changes' do
    subject { delta.changes }

    its(:count) { should == 1 }
    its(:first) { should be_a Dropbox::RecordChanges::Update }
  end

  describe '#to_json' do
    subject { delta.to_json }

    it { should == "[[\"U\",\"table1\",\"123456\",{\"name\":[\"P\",\"hello\"],\"age\":[\"P\",{\"I\":\"20\"}]}]]" }
  end
end
