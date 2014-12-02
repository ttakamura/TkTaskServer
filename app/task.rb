# -*- coding: utf-8 -*-
#["BtVtHRU6I0MMCD0UbmCq5A",
# #<#<Class:0x007fb8f431da80>:0x007fb8f69cb1c8
# @data=
# {:name=>"歯みがき",
#   :section=>0,
#   :elapsed=>0,
#   :rec_start=>"",
#   :done=>true,
#   :date=>"2014-10-23 10:15:30 +0900",
#   :estimate=>5,
#   :row=>0},
# @rowid="BtVtHRU6I0MMCD0UbmCq5A",
# @tid="tasks1">]

class Task < DropbModel
  self.table_id = 'tasks'

  attribute :name
  attribute :elapsed
  attribute :done
end
