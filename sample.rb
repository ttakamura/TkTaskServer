require './lib/dropbox.rb'

store = Dropbox::DataStore.all.first
pp store

records = store.records.all
pp records

store.deltas.all.each do |delta|
  pp delta
end

record = store.records.new tid: 'test', data: {name: 'hoge', age: 22, gender: 'male'}
record.create!

pp record
