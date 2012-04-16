##############################################################################
#   Indis framework                                                          #
#   Copyright (C) 2012 Vladimir "Farcaller" Pouzanov <farcaller@gmail.com>   #
#                                                                            #
#   This program is free software: you can redistribute it and/or modify     #
#   it under the terms of the GNU General Public License as published by     #
#   the Free Software Foundation, either version 3 of the License, or        #
#   (at your option) any later version.                                      #
#                                                                            #
#   This program is distributed in the hope that it will be useful,          #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
#   GNU General Public License for more details.                             #
#                                                                            #
#   You should have received a copy of the GNU General Public License        #
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.    #
##############################################################################

module Indis
  class VMMap
    def initialize(target)
      @target = target
      @blocks = {}
    end
    
    def segment_at(ofs)
      @target.segments.each.find { |s| (s.vmaddr...s.vmaddr+s.vmsize).include? ofs }
    end
    
    def section_at(ofs)
      seg = segment_at(ofs)
      return nil unless seg
      
      seg.sections.each.find { |s| (s.vmaddr...s.vmaddr+s.vmsize).include? ofs }
    end
    
    def address_valid?(ofs)
      segment_at(ofs) != nil
    end
    
    def byte_at(ofs)
      seg = segment_at(ofs)
      return nil unless seg
      
      sect = section_at(ofs) # TODO: optimize here
      s = sect || seg
      
      s.bytes[ofs-s.vmaddr].ord
    end
    
    def bytes_at(ofs, size)
      seg = segment_at(ofs)
      return nil unless seg
      
      sect = section_at(ofs) # TODO: optimize here
      s = sect || seg
      
      st = ofs-s.vmaddr
      ed = st + size
      s.bytes[st...ed].unpack('C*')
    end
    
    def block_at(ofs)
      @blocks[ofs]
    end
    
    def has_unmapped(ofs, size)
      size.times { |o| return false if block_at(ofs+o) }
      true
    end
    
    def map(e)
      raise ArgumentError unless has_unmapped(e.vmaddr, e.size)
      @blocks[e.vmaddr] = e
    end
    
    def map!(e)
      (e.vmaddr...(e.vmaddr+e.size)).each do |ofs|
        b = @blocks[ofs]
        if b
          b.unmap
          @blocks[ofs] = nil
        end
      end
      map(e)
    end
    
    def [](range)
      return block_at(range) if range.is_a?(Fixnum)
      
      raise ArgumentError unless range.is_a?(Range)
      seg = segment_at(range.begin)
      raise ArgumentError unless seg
      raise ArgumentError unless seg == segment_at(range.max)
      
      a = []
      ofs = range.begin
      
      begin
        b = @blocks[ofs]
        if b
          a << b
          (b.size-1).times { a << nil }
          ofs += b.size
        else
          a << seg.bytes[ofs-seg.vmaddr].ord
          ofs += 1
        end
      end while ofs <= range.max
      a
    end
  end
end