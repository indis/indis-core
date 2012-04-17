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
  
  class Symbol
    attr_reader :name, :section, :format_sym, :image, :vmaddr
    
    def initialize(name, section, image, vmaddr, format_sym)
      @name = name
      @section = section
      @image = image
      @format_sym = format_sym
      @vmaddr = vmaddr
    end
    
    def to_s
      "#<Indis::Symbol #{@name} at #{@vmaddr.to_s 16}>"
    end
  end
  
end