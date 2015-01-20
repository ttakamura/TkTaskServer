require 'spec_helper'

describe OrgSchedule do
  let(:sched) { OrgSchedule.new text }

  subject { sched }

  describe 'parse' do
    context 'start-end repeat-rule' do
      let(:text)  { "<2015-01-17 Sat 15:00-16:00 .+1d>" }

      its(:start_time)  { should == Time.parse("2015-01-17T15:00+0900") }
      its(:end_time)    { should == Time.parse("2015-01-17T16:00+0900") }
      its(:repeat_rule) { should == '.+1d' }
    end

    context 'start repeat-rule' do
      let(:text)  { "<2015-01-17 Sat 15:00 .+1d>" }

      its(:start_time)  { should == Time.parse("2015-01-17T15:00+0900") }
      its(:end_time)    { should == nil }
      its(:repeat_rule) { should == '.+1d' }
    end

    context 'start-end' do
      let(:text)  { "<2015-01-17 Sat 15:00-16:00>" }

      its(:start_time)  { should == Time.parse("2015-01-17T15:00+0900") }
      its(:end_time)    { should == Time.parse("2015-01-17T16:00+0900") }
      its(:repeat_rule) { should == nil }
    end

    context 'start' do
      let(:text)  { "<2015-01-17 Sat 05:00>" }

      its(:start_time)  { should == Time.parse("2015-01-17T05:00+0900") }
      its(:end_time)    { should == nil }
      its(:repeat_rule) { should == nil }
    end
  end

  describe 'to_s' do
    context 'start-end repeat-rule' do
      let(:text)  { "<2015-01-17 Sat 15:00-16:00 .+1d>" }

      its(:to_s)  { should == text }
    end

    context 'start repeat-rule' do
      let(:text)  { "<2015-01-17 Sat 15:00 .+1d>" }

      its(:to_s)  { should == text }
    end

    context 'start-end' do
      let(:text)  { "<2015-01-17 Sat 15:00-16:00>" }

      its(:to_s)  { should == text }
    end

    context 'start' do
      let(:text)  { "<2015-01-17 Sat 05:00>" }

      its(:to_s)  { should == text }
    end
  end
end
