require 'indis-core/segment'

describe Indis::Segment do
  it "should provide a correct range for its vm region" do
    seg = Indis::Segment.new(double('Target'), '__TEXT', 0x4096, 120, 0, '')
    seg.to_vmrange.should == (0x4096..0x410e)
  end
  
  it "should provide bytes value based on io offset" do
    seg = Indis::Segment.new(double('Target'), '__TEXT', 0x4096, 10, 0, 'qwertyuiop')
    seg.bytes.should == 'qwertyuiop'
  end
  
  it "should zero-pad bytes if the vm size is bigger" do
    seg = Indis::Segment.new(double('Target'), '__TEXT', 0x4096, 120, 0, 'qwertyuiop')
    seg.bytes.length.should == 120
    seg.bytes.should == 'qwertyuiop' + ("\0"*110)
  end
end