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
  
  # BinaryFormat manages a set of known binary formats and provides support
  # for guessing the correct format for target binary.
  module BinaryFormat
    
    # Returns a list of all known binary formats.
    #
    # @return [Array<Class>] all known binary formats.
    def self.known_formats
      fmt = []
      self.constants.each do |c|
        e = const_get(c)
        fmt << e if e.is_a?(Class) && e.superclass == Format
      end
      fmt
    end
    
    # Base class for any binary format.
    class Format
      # Basic constructor takes care of storing the target and io stream.
      def initialize(target, io)
        @target = target
        @io = io
      end
      
      # @abstract Returns the format magic bytes.
      #
      # @return [Fixnum] Magic bytes that are checked against the first bytes in binary.
      def self.magic
        raise RuntimeError
      end
      
      # @abstract Returns the human-readable format name.
      #
      # @return [String] Human-readable format name.
      def self.name
        raise RuntimeError
      end
    end
    
  end
end
