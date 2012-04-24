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
  
  class CStringEntity < Entity
    attr_reader :value # @return [String] the value of entity
    
    # @param [Fixnum] ofs virtual address
    # @param [Indus::VMMap] vmmap map of the target to load value from
    def initialize(ofs, vmmap)
      super ofs
      
      @value = ''
      addr = ofs
      begin
        c = vmmap.byte_at(addr)
        @value += c.chr
        addr += 1
      end while c != 0
      
      @size = @value.length
    end
    
    def to_s
      "DCB\t\"#{@value[0...-1]}\",0"
    end
    
    def to_a
      ['DCB', "\"#{@value[0...-1]}\",0"]
    end
    
  end
  
end