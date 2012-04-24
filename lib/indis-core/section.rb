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
  
  class Section
    attr_reader :name, :segment
    attr_reader :vmaddr, :vmsize, :bytes
    attr_reader :type, :attributes
    
    def initialize(seg, name, vmaddr, vmsize, iooff, type, attrs)
      @segment = seg
      @name = name
      @vmaddr = vmaddr
      @vmsize = vmsize
      @iooff = iooff
      @type = type
      @attributes = attrs
    end
    
    def to_vmrange
      @vmaddr...(@vmaddr+@vmsize)
    end
    
    def bytes
      s = @iooff - @segment.iooff
      e = s + @vmsize
      @segment.bytes[s...e]
    end
  end
  
end