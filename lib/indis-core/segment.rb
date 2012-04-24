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
  
  # A segment describes one given segment contained in the target binary.
  # Segment's virtual size might be different from physical (stored in file),
  # in this case the data is padded with zeroes
  #
  # @note this class is heavily based on Mach-O
  class Segment
    # Contains a list of current segment sections
    # @return [Array<Indis::Section>]
    attr_reader :sections
    
    attr_reader :target   # @return [Indis::Target] owning target
    
    attr_reader :name     # @return [String] segment name
    
    attr_reader :vmaddr   # @return [Fixnum] starting virtual address
    
    attr_reader :vmsize   # @return [Fixnum] segment size
    
    # The whole (zero-padded if required) bytes string for a segment
    # @return [String]
    attr_reader :bytes
    
    attr_reader :iooff    # @return [Fixnum] offset from the beginning of of file to segment data
    
    # @param [Indis::Target] target the target containing a segment
    # @param [String] name segment name
    # @param [Fixnum] vmaddr starting virtual address
    # @param [Fixnum] vmsize size (in bytes)
    # @param [Fixnum] iooff offset from the beginning of of file to segment data
    # @param [String] bytes known data bytes (loaded from binary)
    def initialize(target, name, vmaddr, vmsize, iooff, bytes)
      @target = target
      @name = name
      @sections = []
      
      @vmaddr = vmaddr
      @vmsize = vmsize
      @iooff = iooff
      @bytes = pad_bytes(bytes)
    end
    
    # Constructs a Range of virtual addresses used by segment
    #
    # @return [Range] the range of all addresses
    def to_vmrange
      @vmaddr...(@vmaddr+@vmsize)
    end
    
    private
    def pad_bytes(bytes)
      bytes + ("\x0" * (@vmsize - bytes.length))
    end
  end

end