require './lib.rb'

store = Dropbox::DataStore.default
pp store

records = store.records.all
pp records

store.deltas.all.each do |delta|
  pp delta
end

record = store.records.new tid: 'test', data: {name: 'hoge', age: 22, gender: 'male'}
record.save!

pp record
