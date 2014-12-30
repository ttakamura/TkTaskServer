# -*- coding: utf-8 -*-
require './app.rb'
require 'org-ruby'

def parse_task line, index
  raise "No ID!! Please set ID in properties by org-mobile-push" unless line.property_drawer['ID']
  {
    :name      => line.headline_text,
    :section   => 1,
    :elapsed   => 0,
    :done      => false,
    :date      => Time.now.to_s,
    :estimate  => 60,
    :row       => index,
    :id        => @namespace + line.property_drawer['ID']
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
  @local_db ||= begin
                  remote_db, local_db = DB.open :default
                  local_db.sync!
                  local_db
                end
end

def save_task task
  task = if current_task = Task.find(task[:id])
           current_task.record.data = task
           current_task
         else
           Task.new task
         end
  task.save!
  task
end

# ------------------------ main -------------------------

file_name = ARGV.shift
raise "Please input the file_name" unless file_name

@namespace = "20141231__"

tasks = parse_tasks(file_name)

tasks.each do |task|
  save_task(task)
end

# binding.pry
