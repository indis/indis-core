require 'indis-core/binaryops_string'

describe BinaryopsString do
  it "should initialize from String" do
    BinaryopsString.new('0110').should == '0110'
    BinaryopsString.new('0110').to_i.should == 0b0110
  end
  
  it "should initialize from Fixnum" do
    BinaryopsString.new(0b0110).should == '110'
    BinaryopsString.new(0b0110).to_i.should == 0b110    
  end
  
  it "should initialize from given zeroes count" do
    BinaryopsString.zeroes(5).should == '00000'
    BinaryopsString.zeroes(5).to_i.should == 0
  end
  
  it "should perform concatenation" do
    BinaryopsString.new('0110').concat(BinaryopsString.new('0001')).to_s.should == '01100001'
  end
  
  it "should perform zero extension" do
    BinaryopsString.new('0110').zero_extend(8).should == '00000110'
    BinaryopsString.new('0110').zero_extend(4).should == '0110'
    BinaryopsString.new('0110').zero_extend(0).should == '0110'
  end
  
  it "should perform sign extension" do
    BinaryopsString.new('1010').sign_extend(8).should == '11111010'
    BinaryopsString.new('0010').sign_extend(8).should == '00000010'
  end
  
  it "should output correct sign on to_signed_i" do
    BinaryopsString.new('11111010').to_signed_i.should == -6
    BinaryopsString.new('00001010').to_signed_i.should == 10
  end
  
  it "should output correct sign on to_i" do
    BinaryopsString.new('11111010').to_i.should == 250
    BinaryopsString.new('00001010').to_i.should == 10
  end
  
  it "should perform lsl / lsr" do
    (BinaryopsString.new('0110') << 1).should == '1100'
    (BinaryopsString.new('0110') >> 1).should == '0011'
    (BinaryopsString.new('0110') << 2).should == '1000'
    (BinaryopsString.new('0110') >> 2).should == '0001'
  end
  
  it "should perform ror" do
    (BinaryopsString.new('0110').ror(1)).should == '0011'
    (BinaryopsString.new('0110').ror(2)).should == '1001'
  end
end