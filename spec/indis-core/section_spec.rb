require 'indis-core/section'

describe Indis::Section do
  it "should provide a correct range for its vm region" do
    sect = Indis::Section.new(double('Segment'), '__text', 0x4096, 120, 0)
    sect.to_vmrange.should == (0x4096..0x410e)
  end
  
  it "should provide bytes value from segment based on io offset" do
    seg = double('Segment', bytes: 'qwertyuiop', iooff: 100)
    sect = Indis::Section.new(seg, '__text', 0x4096, 4, 102)
    sect.bytes.should == 'erty'
  end
end