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

class Fixnum
  def bitlen=(bitlen)
    @bitlen = bitlen
  end
  
  def bitlen
    @bitlen ||= self.to_s(2).length
  end
  
  def set_bitlen(i)
    @bitlen = i
    self
  end
  
  def msb
    self >> (self.bitlen-1)
  end
  
  def to_signed
    if msb == 1
      - ((1 << @bitlen) - self)
    else
      self
    end
  end
  
  alias :old_range :[]
  
  def [](range)
    return old_range(range) unless range.is_a?(Range)
    raise ArgumentError, "Only inclusive ranges are supported" if range.exclude_end?
    (self >> range.begin) & ((1 << (range.end-range.begin+1)) - 1)
  end
end