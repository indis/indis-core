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

require 'indis-core/entity'

module Indis
  
  # DataEntity represens "data bytes" that are directly used e.g. in a load
  # to register instruction. There are four sizes of data: 8, 16, 32 and 64
  # bits long, namely +byte+, +word+, +dword+ and +qword+
  class DataEntity < Entity
    KIND = {
      1 => :byte,
      2 => :word,
      4 => :dword,
      8 => :qword,
    }
    
    NAMED_TYPE = {
      byte:  'DCB',
      word:  'DCW',
      dword: 'DCD',
      qword: 'DCQ'
    }
    
    attr_reader :value # @return [Fixnum] the value of entity
    
    # @param [Fixnum] ofs virtual address
    # @param [Fixnum] size entity size in bytes
    # @param [Indus::VMMap] vmmap map of the target to load value from
    # @raise [AttributeError] if the size is not one of the known values
    def initialize(ofs, size, vmmap)
      raise ArgumentError, "Unaligned size" unless KIND[size]
      super ofs
      @size = size
      @value = vmmap.bytes_at(ofs, size).reverse_each.reduce(0) { |v, i| (v << 8) + i }
    end
    
    # @return [KIND] entity kind
    def kind
      KIND[@size]
    end
    
    def to_s
      "#{NAMED_TYPE[kind]}\t#{sprintf("%0#{@size*2}X", @value)}"
    end
  end
  
end