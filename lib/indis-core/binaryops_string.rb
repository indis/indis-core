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

require 'indis-core/binaryops_fixnum'

# BinaryopsString manages bitwise operations on a String. This is useful when
# you expect bitstrings with meaningful leading zeroes.
class BinaryopsString < String
  # BinaryopsString can be initialized either from a String or a Fixnum
  # @param [String, Fixnum] s source value
  def initialize(s)
    if s.class == Fixnum
      super s.to_s(2)
    else
      super
    end
  end
  
  # Outputs an unsigned int value of self
  def to_i
    super 2
  end
  
  # Outputs a signed int value of self
  def to_signed_i
    return to_i if self[0] == '0'
    complement = ('1'*(self.length)).to_i(2) - to_i + 1
    -complement
  end
  
  # @return a new BinaryopsString with a given slice (rightmost bit is 0)
  # @param [Fixnum] from first bit (inclusive)
  # @param [Fixnum] to last bit (inclusive)
  def bits(from, to)
    BinaryopsString.new(self.to_s[~from..~to])
  end
  
  # @return a new BinaryopsString with a given slice (leftmost bit is 0)
  # @param [Fixnum] from first bit (inclusive)
  # @param [Fixnum] to last bit (inclusive)
  def rbits(from, to)
    BinaryopsString.new(self.to_s[from..to])
  end
  
  # @return a Fixnum with given bit value (rightmost bit is 0)
  # @param [Fixnum] i the bit in question
  def bit(i)
    self[~i].to_i
  end
  
  # @return a Fixnum with given bit value (leftmost bit is 0)
  # @param [Fixnum] i the bit in question
  def rbit(i)
    self[i].to_i
  end
  
  # Performs an OR operation
  # @return a new BinaryopsString with result
  # @raise [ArgumentError] when BinaryopsString lengths don't match
  def |(other)
    raise ArgumentError unless self.length == other.length
    BinaryopsString.new(self.to_i | other.to_i).zero_extend(self.length)
  end
  
  # Concatenates the receiver with another BinaryopsString
  # @return a new BinaryopsString with result
  def concat(other)
    BinaryopsString.new(self.to_s + other.to_s)
  end
  
  # Zero-extends the receiver to given length (left padding)
  # @return a new BinaryopsString with result
  def zero_extend(len)
    return self unless len-self.length > 0
    zbs = '0'*(len-self.length)
    BinaryopsString.new(zbs + self.to_s)
  end
  
  # Sign-extends the receiver to given length (left padding)
  # @return a new BinaryopsString with result
  def sign_extend(len)
    return self unless len-self.length > 0
    zbs = self[0]*(len-self.length)
    BinaryopsString.new(zbs + self.to_s)
  end
  
  # Performs a LSL operation
  # @return a new BinaryopsString with result
  def <<(amount)
    return self if amount == 0
    z = BinaryopsString.zeroes(amount)
    concat(z).bits(self.length-1, 0)
  end
  
  # Performs a LSR operation
  # @return a new BinaryopsString with result
  def >>(amount)
    return self if amount == 0
    z = BinaryopsString.zeroes(amount)
    z.concat(self).rbits(0, self.length-1)
  end
  
  # Performs a ROR operation (cyclic LSR)
  # @return a new BinaryopsString with result
  def ror(amount)
    return self if amount == 0
    s = self.to_s
    moveover = s[-amount..-1]
    movable = s[0...-amount]
    BinaryopsString.new(moveover + movable)
  end
  
  # Returns a new BinaryopsString filled in with zeroes of given length
  def self.zeroes(n)
    BinaryopsString.new('0'*n)
  end
end

class String
  # Helper method to convert String to BinaryopsString
  def to_bo
    BinaryopsString.new(self)
  end
end

class Fixnum
  # Helper method to convert Fixnum to BinaryopsString
  def to_bo
    BinaryopsString.new(self.to_s(2))
  end
  
  # Helper method to convert Fixnum to BinaryopsString with given length
  # (zero-padded)
  def to_boz(len)
    BinaryopsString.new(self.to_s(2)).zero_extend(len)
  end
end