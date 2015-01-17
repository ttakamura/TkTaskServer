# -*- coding: utf-8 -*-
class OrgHeadline
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
    raise "No ID!! Please set ID in properties by org-mobile-push" unless top_headline.property_drawer['ID']
    @self_line    = top_headline
    @state        = top_headline.keyword
    @title        = top_headline.headline_text
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

  def to_s
    "#{'*' * level} #{state_to_s}#{title}#{tags_to_s}"
  end

  def state_to_s
    @state ? @state + ' ' : ''
  end

  def tags_to_s
    tags.empty? ? '' : "   :#{tags.join(':')}:"
  end

  def to_task_attrs
    task = {
      :name           => title,
      :section        => (scheduled_at.start_time.hour / 4).to_i,
      :elapsed        => 0,
      :rec_start      => '',
      :done           => state == 'DONE',
      :date           => Time.now.to_s,
      :estimate       => effort_min,
      :id             => id,
      :scheduled_date => scheduled_at.start_time.iso8601
    }
    task[:section] = 5 if  scheduled_at.start_time.hour == 0
    task
  end

  private
  def parse_effort_min effort=nil
    if effort
      t = Time.parse(effort)
      t.hour * 60 + t.min
    else
      0
    end
  end

  def parse_body_lines body_lines
    body_lines.map do |body_line|
      # puts [body_line.paragraph_type, body_line.to_s]

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
      OrgClockLog.new value
    when /SCHEDULED/
      OrgSchedule.new value
    end
  end
end
