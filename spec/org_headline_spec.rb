# -*- coding: utf-8 -*-
require 'spec_helper'

describe OrgHeadline do
  let(:top) { OrgHeadline.parse_org_file 'spec/fixtures/sample.org' }

  subject { top }

  its(:level)     { should == 0 }
  its(:id)        { should == '0000' }

  describe 'parse_org' do
    describe 'やること' do
      subject { top.headlines.first }

      its(:level)      { should == 1 }
      its(:title)      { should == 'やること' }
      its(:to_s)       { should == '* やること   :TODO:HOME:' }
      its(:id)         { should == 'A001' }
      its(:tags)       { should == ['TODO', 'HOME'] }
      its(:effort_min) { should == 140 }
      its(:clock_logs) { should == [] }

      describe '#properties' do
        subject { top.headlines[0].properties }

        its(['Hoge']) { should == 'hello world' }
      end

      describe 'SCHEDULED: <2015-01-17 Sat 14:00>' do
        subject { top.headlines[0].scheduled_at }

        it { should be_a OrgSchedule }
        its(:start_time)  { should == Time.parse("2015-01-17T14:00+0900") }
        its(:end_time)    { should be_nil }
        its(:repeat_rule) { should be_nil }
      end

      describe '散髪' do
        subject { top.headlines[0].headlines[0] }

        its(:level)      { should == 2 }
        its(:to_s)       { should == '** TODO 散髪' }
        its(:id)         { should == 'A00101' }
        its(:headlines)  { should == [] }
        its(:effort_min) { should == 20 }
        its(:state)      { should == 'TODO' }

        describe 'SCHEDULED: <2015-01-17 Sat 15:00-16:00>' do
          subject { top.headlines[0].headlines[0].scheduled_at }

          it { should be_a OrgSchedule }
          its(:start_time)  { should == Time.parse("2015-01-17T15:00+0900") }
          its(:end_time)    { should == Time.parse("2015-01-17T16:00+0900") }
          its(:repeat_rule) { should be_nil }
        end

        describe 'clock_logs' do
          subject { top.headlines[0].headlines[0].clock_logs }

          # CLOCK: [2015-01-17 Sat 13:31]
          its(:first) { should be_a OrgClockLog }
          its('first.start_time') { should == Time.parse('2015-01-17T13:31+0900') }
          its('first.end_time')   { should == Time.parse('2015-01-17T13:49+0900') }

          # CLOCK: [2015-01-17 Sat 12:38]--[2015-01-17 Sat 12:49] =>  0:11
          its(:last) { should be_a OrgClockLog }
          its('last.start_time') { should == Time.parse('2015-01-17T12:38+0900') }
          its('last.end_time')   { should == Time.parse('2015-01-17T12:49+0900') }
        end

        describe '#body_lines' do
          subject { top.headlines[0].headlines[0].body_lines }

          its([0]) { should == '    - [ ] あれやって' }
          its([1]) { should == '    - これやる' }
          its([2]) { should == '    それする' }
        end
      end

      describe 'KPT' do
        subject { top.headlines[0].headlines[1] }

        its(:level)      { should == 2 }
        its(:to_s)       { should == '** IDEA KPT' }
        its(:id)         { should == 'A00102' }
        its(:headlines)  { should == [] }
        its(:effort_min) { should == 0 }

        describe 'SCHEDULED: <2015-01-17 Sat 16:00-17:00 +1d>' do
          subject { top.headlines[0].headlines[1].scheduled_at }

          it { should be_a OrgSchedule }
          its(:start_time)  { should == Time.parse("2015-01-17T16:00+0900") }
          its(:end_time)    { should == Time.parse("2015-01-17T17:00+0900") }
          its(:repeat_rule) { should == '+1d' }
        end
      end
    end

    describe '買う物' do
      subject { top.headlines.last }

      its(:level) { should == 1 }
      its(:to_s)  { should == '* 買う物' }
      its(:id)    { should == 'A002' }
    end
  end

  describe '#to_task_attrs' do
    subject { top.headlines[0].to_task_attrs }

    its([:name          ]) { should == 'やること' }
    its([:section       ]) { should == 3 }
    its([:elapsed       ]) { should == 0 }
    its([:rec_start     ]) { should == '' }
    its([:done          ]) { should == false }
    its([:estimate      ]) { should == 140 }
    its([:id            ]) { should == 'A001' }
    its([:scheduled_date]) { should == Time.parse('2015-01-17T14:00:00+09:00') }
  end
end
