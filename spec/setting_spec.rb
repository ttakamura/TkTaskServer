require 'spec_helper'

describe Setting do
  subject { Setting }

  its(:env) { should == 'test' }
end
