# coding: utf-8
require 'spec_helper'

describe OrgConverter do
  let(:conv) { OrgConverter.new 'spec/fixtures/sample.org' }

  describe '#parse_tasks' do
    subject { conv.parse_tasks.first }

    its([:name]) { should == 'やること' }
    its([:row])  { should == 0 }
  end
end
