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
  
  # Entity represens an object mapped to some given bytes in the traget's
  # virtual address space
  class Entity
    attr_reader :vmaddr # @return [Fixnum] virtaul address of the entity
    
    # @abstract You must provide @size value in a subclass
    # @return [Fixnum] entity size in bytes
    attr_reader :size
    
    attr_reader :tags # @return [Hash] cross-references and additional attributes of entity
    
    def initialize(ofs)
      @vmaddr = ofs
      @tags = {}
    end
    
    def unmap
      # TODO: Reverse unmap tags
      @tags = nil
    end
  end
  
end