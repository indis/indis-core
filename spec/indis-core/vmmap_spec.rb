require 'indis-core/vmmap'
require 'indis-core/entity'
require 'indis-core/data_entity'

def vmmap_target_double
  double('Target', segments: [
    double('Segment', name: '__PAGEZERO', vmaddr: 0, vmsize: 4096, sections: [],
      bytes: ("\x00"*4096).force_encoding('BINARY'), iooff: 0, to_vmrange: 0...4096),
    double('Segment', name: '__TEXT', vmaddr: 4096, vmsize: 8192, sections: [
      double('Section', name: '__text', vmaddr: 8584, vmsize: 1104, bytes: ("\x0"*1104).force_encoding('BINARY')),
      double('Section', name: '__stub_helper', vmaddr: 9688, vmsize: 156, bytes: ("\x0"*156).force_encoding('BINARY')),
      double('Section', name: '__objc_methname', vmaddr: 9844, vmsize: 1371, bytes: ("\x0"*1371).force_encoding('BINARY')),
      double('Section', name: '__cstring', vmaddr: 11215, vmsize: 148, bytes: ("\x0"*148).force_encoding('BINARY')),
      double('Section', name: '__objc_classname', vmaddr: 11363, vmsize: 62, bytes: ("\x0"*62).force_encoding('BINARY')),
      double('Section', name: '__objc_methtype', vmaddr: 11425, vmsize: 821, bytes: ("\x0"*821).force_encoding('BINARY')),
      double('Section', name: '__symbolstub1', vmaddr: 12248, vmsize: 40, bytes: ("\x0"*40).force_encoding('BINARY'))
    ], bytes: ("\x1\x2\x3\x4\x5\x6\x7\x8\x9"*(8192/8)).force_encoding('BINARY'), iooff: 0, to_vmrange: 4096...12288),
    double('Segment', name: '__DATA', vmaddr: 12288, vmsize: 4096, sections: [
      double('Section', name: '__lazy_symbol', vmaddr: 12288, vmsize: 40, bytes: ("\xbb"*40).force_encoding('BINARY')),
      double('Section', name: '__program_vars', vmaddr: 12336, vmsize: 20, bytes: ("\xbb"*20).force_encoding('BINARY')),
      double('Section', name: '__nl_symbol_ptr', vmaddr: 12356, vmsize: 8, bytes: ("\xbb"*8).force_encoding('BINARY')),
      double('Section', name: '__objc_classlist', vmaddr: 12364, vmsize: 8, bytes: ("\xbb"*8).force_encoding('BINARY')),
      double('Section', name: '__objc_protolist', vmaddr: 12372, vmsize: 8, bytes: ("\xbb"*8).force_encoding('BINARY')),
      double('Section', name: '__objc_imageinfo', vmaddr: 12380, vmsize: 8, bytes: ("\xbb"*8).force_encoding('BINARY')),
      double('Section', name: '__objc_const', vmaddr: 12392, vmsize: 1176, bytes: ("\xbb"*1176).force_encoding('BINARY')),
      double('Section', name: '__objc_selrefs', vmaddr: 13568, vmsize: 72, bytes: ("\xbb"*72).force_encoding('BINARY')),
      double('Section', name: '__objc_classrefs', vmaddr: 13640, vmsize: 16, bytes: ("\xbb"*16).force_encoding('BINARY')),
      double('Section', name: '__objc_superrefs', vmaddr: 13656, vmsize: 8, bytes: ("\xbb"*8).force_encoding('BINARY')),
      double('Section', name: '__objc_data', vmaddr: 13664, vmsize: 80, bytes: ("\xbb"*80).force_encoding('BINARY')),
      double('Section', name: '__objc_ivar', vmaddr: 13744, vmsize: 8, bytes: ("\xbb"*8).force_encoding('BINARY')),
      double('Section', name: '__cfstring', vmaddr: 13752, vmsize: 48, bytes: ("\xbb"*48).force_encoding('BINARY')),
      double('Section', name: '__data', vmaddr: 13800, vmsize: 88, bytes: ("\xbb"*88).force_encoding('BINARY')),
      double('Section', name: '__common', vmaddr: 13888, vmsize: 16, bytes: ("\xbb"*16).force_encoding('BINARY'))
    ], bytes: ("\xBB"*4096).force_encoding('BINARY'), iooff: 0, to_vmrange: 12288...16384),
    double('Segment', name: '__LINKEDIT', vmaddr: 16384, vmsize: 12288, sections: [],
      bytes: ("\xCC"*12288).force_encoding('BINARY'), iooff: 0, to_vmrange: 16384...28672)
  ])
end

describe Indis::VMMap do
  it "should parse existing segments/sections and provide a linear map" do
    map = Indis::VMMap.new(vmmap_target_double)
    
    map.segment_at(0).name.should == '__PAGEZERO'
    map.segment_at(4095).name.should == '__PAGEZERO'
    map.section_at(4095).should be_nil
    
    map.segment_at(4096).name.should == '__TEXT'
    map.section_at(11215).name.should == '__cstring'
    map.segment_at(16400).name.should == '__LINKEDIT'
  end
  
  it "should return nil for address out of known segment bounds" do
    map = Indis::VMMap.new(vmmap_target_double)
    
    map.address_valid?(13664).should == true
    map.address_valid?(16384+12288).should == false
    
    map.byte_at(0).should == 0x00
    map.byte_at(4096).should == 0x01
    map.byte_at(16384+12288).should be_nil
  end
  
  it "should allow to create entities" do
    map = Indis::VMMap.new(vmmap_target_double)
    
    map[13800].should be_nil
    de = Indis::DataEntity.new(13800, 4, map)
    map.map(de)
    map[13800].should_not be_nil
    map[13800].should == de
    map[13800...13804].should == [de, nil, nil, nil]
  end
  
  it "should allow to force-map entities" do
    map = Indis::VMMap.new(vmmap_target_double)
    
    de4 = Indis::DataEntity.new(13800, 4, map)
    map.map(de4)

    de2 = Indis::DataEntity.new(13800, 2, map)
    expect { map.map(de2) }.to raise_error(ArgumentError)
    map.map!(de2)
    map[13800].should == de2
    map[13800...13804].should == [de2, nil, 0xbb, 0xbb]
  end
  
  it "should return an entity when one has been defined previously" do
    map = Indis::VMMap.new(vmmap_target_double)
    
    map[13800].should be_nil
    map.map(Indis::DataEntity.new(13800, 4, map))
    
    b = map[13800]
    b.should be_a(Indis::DataEntity)
    b.size.should == 4
    b.kind.should == :dword
    b.value.should == 0xbbbbbbbb
  end
  
  it "should return correct size for slice" do
    t = vmmap_target_double
    text_seg = t.segments[1]
    map = Indis::VMMap.new(t)
    
    map[text_seg.vmaddr..(text_seg.vmaddr+3)].length.should == 4
    map[text_seg.vmaddr...(text_seg.vmaddr+3)].length.should == 3
  end
  
  it "should return raw bytes in slice" do
    t = vmmap_target_double
    text_seg = t.segments[1]
    map = Indis::VMMap.new(t)
    
    map[text_seg.vmaddr..(text_seg.vmaddr+3)].should == [1, 2, 3, 4]
  end
  
  it "should return entities with nil padding in slice" do
    t = vmmap_target_double
    text_seg = t.segments[1]
    map = Indis::VMMap.new(t)
    
    b = Indis::DataEntity.new(text_seg.vmaddr+1, 2, map)
    map.map(b)
    
    map[text_seg.vmaddr..(text_seg.vmaddr+3)].should == [1, b, nil, 4]
  end
  
  it "should return segment map as an array" do
    t = vmmap_target_double
    text_seg = t.segments[1]
    map = Indis::VMMap.new(t)
    
    a = map[text_seg.to_vmrange]
    a.should_not be_nil
    a.length.should == 8192
  end
  
  it "should map segment bytes to Fixnum when not resolved" do
    t = vmmap_target_double
    text_seg = t.segments[1]
    map = Indis::VMMap.new(t)
    
    a = map[text_seg.to_vmrange]
    a.each { |v| v.class.should == Fixnum }
  end
  
  it "should map segment bytes to entities when resolved" do
    t = vmmap_target_double
    data_seg = t.segments[2]
    map = Indis::VMMap.new(t)
    
    map.map(Indis::DataEntity.new(13800, 4, map))
    a = map[data_seg.to_vmrange]
    a.each_with_index do |v, idx|
      case idx
      when 1512
        v.should be_a(Indis::DataEntity)
      when 1513
      when 1514
      when 1515
        v.should be_nil
      else
        v.should be_a(Fixnum)
      end
    end
  end
end