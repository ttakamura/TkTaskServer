require './app.rb'

remote, local = DB.open :default
local.sync!

pp remote
pp local

records = local.records.all

pp records

local.deltas.all.each do |delta|
  pp delta
end

record = local.records.new tid: 'test', data: {name: 'hoge', age: 22, gender: 'male'}
record.save!

pp record

# ------------------------------------

ModelBase.db = local
