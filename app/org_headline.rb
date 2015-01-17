# -*- coding: utf-8 -*-
class OrgHeadline
  EMACS_DATE_FORMAT = "%Y-%m-%d %a %H:%M"

  extend Forwardable
  attr_reader :headlines, :id, :tags, :level, :title, :effort_min,
              :scheduled_at, :clock_logs, :properties, :body_lines

  class << self
    def parse_org_file file_name
      parse_org open(file_name, 'r:UTF-8').read
    end

    def parse_org text
      parse_headlines Top.new, Orgmode::Parser.new(text).headlines
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
    @todo         = top_headline.keyword
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
    "#{'*' * level} #{todo_to_s}#{title}#{tags_to_s}"
  end

  def todo_to_s
    @todo ? @todo + ' ' : ''
  end

  def tags_to_s
    tags.empty? ? '' : "   :#{tags.join(':')}:"
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
        when ClockLog
          @clock_logs << metadata
        when Schedule
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
      ClockLog.new value
    when /SCHEDULED/
      Schedule.new value
    end
  end

  # -------- metadata --------------------------------------------------
  class Schedule
    attr_reader :start_time, :end_time, :repeat_rule

    def initialize scheduled_text
      @text        = scheduled_text
      @start_time  = parse_next_start_time scheduled_text
      @end_time    = parse_next_end_time   scheduled_text
      @repeat_rule = parse_time(scheduled_text)[:repeat]
    end

    private
    def parse_next_start_time text
      time = parse_time text
      Time.parse time[:date] + " " + time[:start_time] if time[:start_time]
    end

    def parse_next_end_time text
      time = parse_time text
      Time.parse time[:date] + " " + time[:end_time]   if time[:end_time]
    end

    def parse_time text
      # <2015-01-17 Sat 14:00-19:40>
      if m = text.match(/^<(\d{4}-\d{2}-\d{2}) .+? (\d{2}:\d{2})(-(\d{2}:\d{2}))? ?(.+)?>$/)
        all, date, start_time, x, end_time, repeat_rule = m.to_a
        {date: date, start_time: start_time, end_time: end_time, repeat: repeat_rule}
      end
    end
  end

  class ClockLog
    attr_reader :start_time, :end_time

    def initialize text
      range = parse_range(text)
      @start_time = Time.parse(range[:start_time]) if range[:start_time]
      @end_time   = Time.parse(range[:end_time])   if range[:end_time]
    end

    private
    def parse_range text
      # [2014-12-31 Wed 05:44]--[2014-12-31 Wed 06:52] =>  1:08
      if m = text.match(/\[(.+?)\](--\[(.+?)\])?(\s+=>\s+(.+?))?$/)
        all, begin_time, sep, end_time, sep2, span = m.to_a
        {start_time: begin_time, end_time: end_time}
      end
    end
  end

  # --------------------------------
  # 最上位を表現する Null オブジェクト
  #
  class Top
    def level
      0
    end

    def property_drawer
      {'ID' => '0000'}
    end

    def tags
      []
    end

    def headline_text
      ""
    end

    def keyword
      nil
    end

    def body_lines
      []
    end
  end
end
