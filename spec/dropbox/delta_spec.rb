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

  describe '#changes_to_json' do
    subject { delta.changes_to_json }

    it { should == "[[\"U\",\"table1\",\"123456\",{\"name\":[\"P\",\"hello\"],\"age\":[\"P\",{\"I\":\"20\"}]}]]" }
  end

  describe '#serialize' do
    let(:hash) { delta.serialize }

    subject { hash }

    its([:rev])     { should == 10 }
    its([:changes]) { should be_a Array }

    describe 'to_json' do
      subject { hash.to_json }

      it { should == "{\"rev\":10,\"changes\":[[\"U\",\"table1\",\"123456\",{\"name\":[\"P\",\"hello\"],\"age\":[\"P\",{\"I\":\"20\"}]}]],\"nonce\":null}" }
    end
  end

  describe 'pack' do
    subject { delta.pack }

    it { should be_a String }

    describe 'unpack' do
      subject { data_store.deltas.unpack delta.pack }

      its(:rev) { should == 10 }
      its('changes.first') { should be_a Dropbox::RecordChanges::Update }
    end
  end
end
