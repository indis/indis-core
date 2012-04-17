require 'indis-core/target'

describe Indis::Target do
  it "should require an existing file to operate" do
    expect { Indis::Target.new("qwerty") }.to raise_error
  end
  
  it "should load file for known format" do
    fmt = double('MachO Class', magic: 0xfeedface, name: 'Mach-O', new: double('MachO'))
    Indis::BinaryFormat.stub(:known_formats).and_return([fmt])
    t = Indis::Target.new("spec/fixtures/single-object.o")
    t.load
    t.io.length.should_not == 0
    t.format.should_not be_nil
  end
  
  it "should raise if there is no known format to process binary" do
    expect { Indis::Target.new("spec/fixtures/single-object.o") }.to raise_error(RuntimeError)
  end
  
  it "should trigger load event" do
    fmt = double('MachO Class', magic: 0xfeedface, name: 'Mach-O', new: double('MachO'))
    Indis::BinaryFormat.stub(:known_formats).and_return([fmt])
    t = Indis::Target.new("spec/fixtures/single-object.o")
    
    lis = double('Listener')
    lis.should_receive(:target_load_complete)
    
    t.subscribe_for_event(:target_load_complete, lis)
    
    t.load
  end
  
  it "should queue up events that happen before load" do
    fmt = double('MachO Class', magic: 0xfeedface, name: 'Mach-O', new: double('MachO'))
    Indis::BinaryFormat.stub(:known_formats).and_return([fmt])
    t = Indis::Target.new("spec/fixtures/single-object.o")
    
    lis = double('Listener')
    lis.should_receive(:early_event).twice
    
    t.subscribe_for_event(:early_event, lis)
    
    t.publish_event(:early_event)
    t.publish_event(:early_event)
    
    t.load
  end
  
  it "should pass arguments to event subscriptions" do
    fmt = double('MachO Class', magic: 0xfeedface, name: 'Mach-O', new: double('MachO'))
    Indis::BinaryFormat.stub(:known_formats).and_return([fmt])
    t = Indis::Target.new("spec/fixtures/single-object.o")
    t.load
    
    lis = double('Listener')
    lis.should_receive(:event_with_args).with(1, 2).once
    
    t.subscribe_for_event(:event_with_args, lis)
    
    t.publish_event(:event_with_args, 1, 2)
  end
end