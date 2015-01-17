require 'ostruct'
require 'pry'
require 'hirb-unicode'
require 'org-ruby'
Hirb.disable

require File.expand_path("../lib.rb", __FILE__)
require File.expand_path("../app/text_mapper.rb", __FILE__)
require File.expand_path("../app/dropb_model.rb", __FILE__)
require File.expand_path("../app/task.rb", __FILE__)
require File.expand_path("../app/org_headline.rb", __FILE__)
