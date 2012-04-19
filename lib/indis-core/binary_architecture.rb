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
  
  # BinaryArchitecture manages all known architectures and provides support
  # for resolving the correct class for named architecture
  module BinaryArchitecture
    
    def self.known_archs
      fmt = {}
      self.constants.each do |c|
        e = const_get(c)
        fmt[e.name] = e if e.is_a?(Class) && e.superclass == Architecture
      end
      fmt
    end
    
    # Base class for any binary architecture
    class Architecture
      # Basic constructor takes care of storing the target
      def initialize(target)
        @target = target
      end
      
      # @abstract Returns the format magic bytes.
      #
      # @return [Symbol] symbolicated name of the architecture
      def self.name
        raise RuntimeError, "#name not implemented in architecture #{self.class}"
      end
    end
    
  end
end