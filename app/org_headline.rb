# -*- coding: utf-8 -*-
class OrgHeadline
  include ::OrgExporter::SerializeOrgHeadline
  extend Forwardable
  attr_reader :headlines, :id, :tags, :level, :title, :effort_min, :state,
              :scheduled_at, :clock_logs, :properties, :body_lines

  class << self
    def parse_org_file file_name
      parse_org open(file_name, 'r:UTF-8').read
    end

    def parse_org text
      parse_headlines OrgHeadlineTop.new, Orgmode::Parser.new(text).headlines
    end

    private
    def parse_headlines current, headlines
      children = []
      while headlines.first && headlines.first.level > current.level
        line = headlines.shift
        children << parse_headlines(line, headlines)
      end
      self.new current, children
    end
  end

  def initialize top_headline, headlines=[]
    if m = top_headline.headline_text.match(/(IDEA|TODO|DONE|NEXT|FOCUS|WAIT|SOMEDAY) /)
      keyword = m[1]
    else
      keyword = top_headline.keyword
    end
    @self_line    = top_headline
    @state        = keyword
    @title        = top_headline.headline_text.gsub(/(IDEA|TODO|DONE|NEXT|FOCUS|WAIT|SOMEDAY) /, '')
    @level        = top_headline.level
    @id           = top_headline.property_drawer['ID']
    @tags         = top_headline.tags
    @effort_min   = parse_effort_min top_headline.property_drawer['Effort']
    @properties   = top_headline.property_drawer

    # body
    @scheduled_at = nil
    @clock_logs   = []
    @body_lines   = parse_body_lines top_headline.body_lines

    # children
    @headlines    = headlines
  end

  def to_task_attrs
    task = {
      :name           => title,
      :section        => 0,
      :elapsed        => 0,
      :rec_start      => '',
      :done           => state == 'DONE',
      :estimate       => effort_min,
      :id             => id,
      :scheduled_date => nil,
      :state          => state || 'NONE'
    }

    task[:clock_logs] = clock_logs.reverse.map(&:to_a).compact.flatten

    if scheduled_at && scheduled_at.start_time
      task[:section]        = (scheduled_at.start_time.hour / 4).to_i
      task[:section]        = 5 if scheduled_at.start_time.hour == 0
      task[:scheduled_date] = scheduled_at.start_time
    end

    task
  end

  def done!
    @state = 'DONE'
  end

  def arrange_conflict_tasks!
    next_free_time = nil
    sorted_headlines.each do |sub|
      schedule = sub.scheduled_at

      if next_free_time
        if schedule.start_time < next_free_time
          schedule.end_time   = next_free_time + schedule.effort_sec
          schedule.start_time = next_free_time
        end
      end

      next_free_time = schedule.end_time
    end
  end

  def sorted_headlines
    list = all_sub_headlines

    list = list.find_all do |sub_headline|
      sub_headline.scheduled_at &&
      sub_headline.scheduled_at.start_time &&
      sub_headline.scheduled_at.end_time
    end

    list.sort_by do |sub_headline|
      s = sub_headline.scheduled_at
      [s.start_time, s.end_time]
    end
  end

  def family_tree
    [self] + headlines.map do |sub|
      sub.family_tree
    end
  end

  def all_sub_headlines
    headlines.map(&:family_tree).flatten
  end

  private
  def parse_effort_min effort=nil
    if effort
      effort = effort == '00:60' ? '01:00' : effort
      t = Time.parse(effort)
      t.hour * 60 + t.min
    else
      0
    end
  end

  def parse_body_lines body_lines
    body_lines.map do |body_line|
      case body_line.paragraph_type
      when :metadata
        metadata = parse_metadata_line(body_line)
        case metadata
        when OrgClockLog
          @clock_logs << metadata
        when OrgSchedule
          @scheduled_at = metadata
        else
          puts "Unknown metadata - #{body_line}"
        end
        nil

      when :list_item
        body_line.to_s

      when :paragraph
        body_line.to_s

      else
        nil
      end
    end.compact
  end

  def parse_metadata_line line
    key, value = line.to_s.split(": ").map{ |v| v.gsub(/(^\s*|\s*$)/, '') }
    case key
    when /CLOCK/
      OrgClockLog.parse value
    when /SCHEDULED/
      OrgSchedule.new value
    end
  end
end
