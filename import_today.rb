# -*- coding: utf-8 -*-
require './app.rb'

def local_db
  Task.db
end

#
# ---------------------- IMPORT --------------------------
#
def import! file_name
  Task.sync!

  if @opts[:reset] == 'true'
    reset_tasks!
  end

  tasks = OrgConverter.new(file_name).parse_tasks

  Task.transaction do
    tasks.each do |task|
      if task[:id]
        save_task(task)
      end
    end
  end
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
  task.save!
  task
end

def reset_tasks!
  Task.transaction do
    Task.all.each do |t|
      t.destroy!
    end
  end
end

#
# ----------------------- EXPORT -----------------------
#
def export! file_name
  org_root = OrgHeadline.parse_org_file file_name
  exporter = OrgExporter.new

  Task.db.deltas.watch do |record|
    if record.rowid && !record.data[:id] && record.tid == Task.table_id
      task     = Task.new record
      headline = task.to_org_headline
      exporter.print_headline headline
    end
  end

  Task.sync!

  Task.transaction do
    pull_changes_headline org_root
  end

  org_root.headlines.each do |headline|
    exporter.print_headline headline
  end
end

def pull_changes_headline headline
  headline.headlines.each do |sub_head|
    pull_changes_headline sub_head
  end

  return headline unless headline.id
  return headline unless task = Task.find_by(id: headline.id)

  if task.done
    headline.done!
  end

  if headline.clock_logs.count < task.org_clock_logs.count
    (task.org_clock_logs - headline.clock_logs).each do |log|
      headline.clock_logs << log
    end
  end
end

#
# ----------------------- ARRANGE -----------------------
#
def arrange! file_name
  org_root = OrgHeadline.parse_org_file file_name
  exporter = OrgExporter.new

  org_root.arrange_conflict_tasks!

  org_root.headlines.each do |headline|
    exporter.print_headline headline
  end
end

# ------------------------ main -------------------------

@opts = Slop.parse(help: true, strict: true) do
  banner 'Usage: import_today.rb [options]'

  on 'f', 'file=',  'Import org-file'
  on 'r', 'reset=', 'Reset all tasks before import', default: 'false'
  on 'm', 'mode=',  'Export/Import mode',            default: 'import'
  on 'v', 'verbose=', 'Verbose mode',                default: 'false'
end

file_name = @opts[:file]
raise "Please input the file_name" unless file_name

case @opts[:mode]
when 'import'
  import! file_name
when 'export'
  export! file_name
when 'arrange'
  arrange! file_name
else
  raise 'Unknown mode is given!'
end
