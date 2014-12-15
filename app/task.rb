# -*- coding: utf-8 -*-
class Task < DropbModel
  self.table_id = 'tasks'

  attribute :name
  attribute :section
  attribute :row
  attribute :estimate
  attribute :elapsed
  attribute :done
  attribute :date
  attribute :rec_start
end

#
#<Task:0x007fc516809728
# @record=
#  #<#<Class:0x007fc5148c5010>:0x007fc51680a6f0
#   @data=
#    {:name=>"ホワイトボードを消す",
#     :section=>1,
#     :elapsed=>0,
#     :rec_start=>"",
#     :done=>false,
#     :date=>"2014-12-14 07:16:49 +0900",
#     :estimate=>3,
#     :row=>0},
#   @rowid="IvuDhxAefasWrl6WqOnIVw",
#   @tid="tasks">>
#
#   class func sectionOptions() -> [Int] {
#       return [0, 1, 2, 3, 4, 5, 6, 7, 8]
#   }
#
#   class func sectionTitles() -> [String] {
#       return ["就寝", "起床", "早朝", "朝", "正午", "昼", "夕方", "夜", "深夜"]
#   }
#
#   class func sectionStartHour() -> [Int] {
#       return [0, 5, 6, 9, 12, 13, 16, 19, 21]
#   }
#
