require 'indis-core/cstring_entity'

describe Indis::CStringEntity do
  it "should load its value from vmmap" do
    str = "hello\0world".unpack('C*')
    map = double('VMMap')
    map.should_receive(:byte_at) { |i| str[i] }.exactly(6).times
    e = Indis::CStringEntity.new(0, map)
    e.to_s.should == "DCB\t\"hello\",0"
    e.value.should == "hello\x0"
  end
end
