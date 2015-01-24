require 'spec_helper'

describe OrgClockLog do
  let(:log)  { OrgClockLog.parse text }

  subject { log }

  describe 'parse' do
    context 'start--end' do
      let(:text) { '[2014-12-31 Wed 05:44]--[2014-12-31 Wed 06:52] =>  1:08' }

      its(:start_time) { should == Time.parse('2014-12-31T05:44+0900') }
      its(:end_time)   { should == Time.parse('2014-12-31T06:52+0900') }
    end

    context 'start' do
      let(:text) { '[2014-12-31 Wed 05:44]' }

      its(:start_time) { should == Time.parse('2014-12-31T05:44+0900') }
      its(:end_time)   { should be_nil }
    end

    context 'wrong format' do
      let(:text) { '[2014-12-31 Wed 05:44]--' }

      it do
        expect{ subject }.to raise_error(/Cannot parse OrgClockLog/)
      end
    end
  end

  describe 'to_s' do
    context 'start--end' do
      let(:text) { '[2014-12-31 Wed 05:44]--[2014-12-31 Wed 06:52] =>  1:08' }

      its(:to_s) { should == text }
    end

    context 'start' do
      let(:text) { '[2014-12-31 Wed 05:44]' }

      its(:to_s) { should == text }
    end
  end
end
