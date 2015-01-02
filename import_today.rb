# -*- coding: utf-8 -*-
require './app.rb'
require 'org-ruby'

POMODORO_ICON = "🍅"

def parse_metadata_line line
  key, value = line.to_s.split(": ").map{ |v| v.gsub(/(^\s*|\s*$)/, '') }
  case key
  when /CLOCK/
    # [2014-12-31 Wed 05:44]--[2014-12-31 Wed 06:52] =>  1:08
    all, begin_time, sep, end_time, sep2, span = value.match(/\[(.+?)\](--\[(.+?)\])?(\s+=>\s+(.+?))?$/).to_a
    if begin_time && end_time
      {begin_date: Time.parse(begin_time), end_date: Time.parse(end_time)}
    else
      {}
    end
  when /SCHEDULED/
    # <2015-01-02 Fri 10:00>
    time = Time.parse value.match(/<(.+)(>)?$/)[1]
    {scheduled_date: time}
  end
end

def parse_task line, index
  raise "No ID!! Please set ID in properties by org-mobile-push" unless line.property_drawer['ID']

  #
  # t.headline_text
  # t.tags            => [""]
  # t.property_drawer => {"id" => "aaa"}
  # t.level           => 2
  # t.keyword         => "TODO"
  #
  # t.body_lines[8].paragraph_type
  # => :list_item
  # t.body_lines[1].paragraph_type
  # => :metadata
  # t.body_lines[0].paragraph_type
  # => :heading2
  #

  task = {
    :name      => line.headline_text,
    :section   => 0,
    :elapsed   => 0,
    :rec_start => '',
    :done      => line.keyword == 'DONE',
    :date      => Time.now.to_s,
    :estimate  => line.headline_text.count(POMODORO_ICON) * 30,
    :id        => line.property_drawer['ID']
  }

  line.body_lines.each do |body_line|
    if body_line.paragraph_type == :metadata
      metadata = parse_metadata_line(body_line)

      if metadata[:scheduled_date]
        task[:section]        = (metadata[:scheduled_date].hour / 4).to_i
        task[:scheduled_date] = metadata[:scheduled_date].to_s
      end

      if metadata[:begin_date] && metadata[:end_date]
        task[:elapsed] += (metadata[:end_date] - metadata[:begin_date]).to_i
      end
    end
  end

  puts "Create/Update task - #{task}"

  task
end

def parse_tasks file_name
  org   = Orgmode::Parser.new(open(file_name, 'r').read)
  tasks = []
  begin_tasks = false

  org.headlines.each do |headline|
    if begin_tasks
      if headline.level == 1
        begin_tasks = false
      else
        tasks << parse_task(headline, tasks.count)
      end
    elsif headline.headline_text =~ /^今日のTODO/
      begin_tasks = true
    end
  end

  sections = Hash.new{ |h,k| h[k] = [] }
  tasks.each do |task|
    sections[task[:section]] << task
  end

  sections.each do |sec, children|
    children.each_with_index do |task, index|
      task[:row] = index
    end
  end

  # binding.pry
  # raise 'stop'

  tasks
end

def local_db
  Task.db
end

def save_task task
  task = if current_task = Task.find_by(id: task[:id])
           puts "Update #{current_task} to #{task}"
           current_task.record.data = task
           current_task
         else
           puts "Create #{task}"
           Task.new task
         end
  task.save! sync: true
  task
end

# ------------------------ main -------------------------

file_name = ARGV.shift
raise "Please input the file_name" unless file_name

tasks = parse_tasks(file_name)

tasks.each do |task|
  save_task(task)
end

local_db.sync!

# binding.pry
