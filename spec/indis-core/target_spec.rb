require 'indis-core/target'

describe Indis::Target do
  it "should require an existing file to operate" do
    expect { Indis::Target.new("qwerty") }.to raise_error
  end
  
  it "should load file for known format" do
    fmt = double('MachO', magic: 0xfeedface, name: 'Mach-O', new: nil)
    Indis::BinaryFormat.stub(:known_formats).and_return([fmt])
    t = Indis::Target.new("spec/fixtures/single-object.o")
    t.io.length.should_not == 0
  end
  
  it "should raise if there is no known format to process binary" do
    expect { Indis::Target.new("spec/fixtures/single-object.o") }.to raise_error(RuntimeError)
  end
end