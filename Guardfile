require 'guard/rspec'

guard :rspec, cmd: 'bundle exec rspec --no-drb --fail-fast' do
  watch(%r{^spec/(.+_spec\.rb)$}) {|m| "spec/#{m[1]}" }
  watch(%r{^lib/(.+)\.rb$})       {|m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')
  watch(%r{^spec/support/(.+)\.rb$})
end
