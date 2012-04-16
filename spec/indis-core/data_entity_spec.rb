require 'indis-core/data_entity'

describe Indis::DataEntity do
  it "should load its value from vmmap" do
    map = double('VMMap', bytes_at: [1, 2, 3, 4])
    e = Indis::DataEntity.new(0, 4, map)
    e.to_s.should == "DCD\t04030201"
  end
  
  it "should raise an erorr if the size is bad" do
    expect { Indis::DataEntity.new(0, 3, nil) }.to raise_error(ArgumentError)
  end
end