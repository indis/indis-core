require 'indis-core/binary_format'

describe Indis::BinaryFormat do
  it "provides no formats on its own" do
    Indis::BinaryFormat.known_formats.length.should == 0
  end
end