# -*- coding: utf-8 -*-
require './app.rb'
require 'org-ruby'

def parse_task line, index
  raise "No ID!! Please set ID in properties by org-mobile-push" unless line.property_drawer['ID']
  {
    :name      => line.headline_text,
    :section   => 2,
    :elapsed   => 0,
    :rec_start => '',
    :done      => false,
    :date      => Time.now.to_s,
    :estimate  => 60,
    :row       => index,
    :id        => line.property_drawer['ID']
  }
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
