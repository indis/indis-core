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
  
  # VMMap provides access to target's virtaul memory address space
  class VMMap
    def initialize(target)
      @target = target
      @blocks = {}
    end
    
    # @return [Indis::Segment] a segment at given address or nil
    def segment_at(ofs)
      @target.segments.each.find { |s| (s.vmaddr...s.vmaddr+s.vmsize).include? ofs }
    end
    
    # @return [Indis::Section] a section at given address or nil
    def section_at(ofs)
      seg = segment_at(ofs)
      return nil unless seg
      
      seg.sections.each.find { |s| (s.vmaddr...s.vmaddr+s.vmsize).include? ofs }
    end
    
    # @return True if the address belongs to some segment
    def address_valid?(ofs)
      segment_at(ofs) != nil
    end
    
    # @return [Fixnum] a byte value at given virtual address
    def byte_at(ofs)
      seg = segment_at(ofs)
      return nil unless seg
      
      sect = section_at(ofs) # TODO: optimize here
      s = sect || seg
      
      s.bytes[ofs-s.vmaddr].ord
    end
    
    # @return [Array<Fixnum>] a list of bytes at given virtual address span
    def bytes_at(ofs, size)
      seg = segment_at(ofs)
      return nil unless seg
      
      sect = section_at(ofs) # TODO: optimize here
      s = sect || seg
      
      st = ofs-s.vmaddr
      ed = st + size
      s.bytes[st...ed].unpack('C*')
    end
    
    # @return [Indis::Entity] an entity mapped to given address
    def entity_at(ofs)
      @blocks[ofs]
    end
    
    # @return True if the given range contains no entities
    def has_unmapped(ofs, size)
      size.times { |o| return false if entity_at(ofs+o) }
      true
    end
    
    # Maps an {Indis::Entity entity} (based on its offset).
    # @raise [ArgumentError] if the range is occupied by another entity
    def map(e)
      raise ArgumentError unless has_unmapped(e.vmaddr, e.size)
      @blocks[e.vmaddr] = e
    end
    
    # Forcefully maps an {Indis::Entity entity} (based on its offset) unmapping
    # any other entities in the same address range
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
    
    # @overload [](ofs)
    #   Returns an entity at given address, same as {VMMap#entity_at}
    #   @todo should also return one-byte
    #   @param [Fixnum] range offset for entity
    #   @return [Indis::Entity] an entity mapped to given address
    # @overload [](range)
    #   Returns a list of entities and bytes at given range. The resulting Array
    #   contains all bytes in range. For each {Indis::Entity entity} it is mapped
    #   "as-is" and the following bytes up to {Indis::Entity#size} are filled with
    #   nil's. For each unmapped byte it is returned as a Fixnum
    #
    #   @param [Range] range range
    #   @return [Array<Indis::Entity,nil,Fixnum>] mapped entities
    #   @raise [ArgumentError] if there is no segment at given range or the range spans several segments
    def [](range)
      return entity_at(range) if range.is_a?(Fixnum)
      
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