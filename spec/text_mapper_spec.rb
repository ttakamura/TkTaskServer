require 'spec_helper'

describe TextMapper, vcr: {cassette_name: 'dropbox_api', record: VCR_RECORD}  do
  let(:klass) do
    Class.new(DropbModel) do
      extend TextMapper

      self.table_id = 'sandbox'

      attribute :id
      attribute :name
      attribute :age
      attribute :secret, render: false
    end
  end

  let(:tom)  { klass.new id: 1, name: 'Tom',  age: 29, secret: 'Banana' }
  let(:john) { klass.new id: 2, name: 'John', age: 30, secret: 'Apple'  }

  describe '#to_table_text' do
    subject { klass.to_table_text [tom, john] }

    it do
      table = <<EOT
+----+------+-----+
| id | name | age |
+----+------+-----+
| 1  | Tom  | 29  |
| 2  | John | 30  |
+----+------+-----+
EOT
      should == table.chomp
    end
  end
end
