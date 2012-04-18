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

require 'indis-core/binary_format'
require 'indis-core/vmmap'

module Indis

  # The main entry point for indis. Target describes a given binary, performs
  # format matching, loading the binary into memory and primary processing.
  class Target
    attr_reader :io     # @return [IO] IO object for target binary
    
    attr_reader :format # @return [Indis::BinaryFormat::Format] binary format of the target
    
    attr_reader :vmmap  # @return [Indis::VMMap] virtual memory map

    attr_accessor :segments # @return [Array<Indis::Segment>] list of all processed {Indis::Segment segments}
    
    attr_accessor :symbols  # @return [Array<Indis::Symbol>] list of all processed {Indis::Symbol symbols}
    
    # @param [String] filename target binary file name
    # @raise [AttributeError] if the file does not exist
    # @raise [RuntimeError] if there is no known format for magic or there are several matching formats
    def initialize(filename)
      raise ArgumentError, "File does not exist" unless FileTest.file?(filename)
      @filename = filename
      @io = StringIO.new(File.open(filename).read().force_encoding('BINARY'))
      
      magic = @io.read(4).unpack('V')[0]
      @io.seek(-4, IO::SEEK_CUR)

      fmts = BinaryFormat.known_formats.map { |f| f if f.magic == magic }.compact
      
      raise RuntimeError, "Unknown format for magic #{magic.to_s(16)}" if fmts.length == 0
      raise RuntimeError, "Several possible formats: #{fmts}" if fmts.length > 1
      
      @format_class = fmts.first
      @format_load_complete = false
    end
    
    # Perform format load and set up a vm map
    def load
      raise RuntimeError, "Already loaded" unless @format_class
      @format = @format_class.new(self, @io)
      @format_class = nil
      
      @vmmap = VMMap.new(self)

      @format_load_complete = true
      replay_queue
      publish_event :target_load_complete
    end
    
    # A target can consist of several other targets (e.g. fat mach-o). In such
    # a case the target is +meta+. It does not have any segments, sections or vmmap,
    # but it has one or several subtargets.
    # @todo implement meta targets
    # @return True if the target is a meta target
    def meta?
      @subtargets && @subtargets.length > 0
    end
    
    # External class can subscribe for events happening with target
    #
    # @param [Symbol] event event name
    # @param listener event listener
    def subscribe_for_event(event, listener)
      subscriptions_array(event) << listener
    end
    
    # Post an event with optional payload. All events queue up until #load ends
    #
    # @param [Symbol] event event name
    def publish_event(event, *args)
      if @format_load_complete == true
        subscriptions_array(event).each { |s| s.send(event, *args) }
      else
        enqueue_event(event, args)
      end
    end
    
    # Resolves a symbol at given virtual address. Targe does so by first checking
    # the locally available symbols, and falls back to format specific resolver
    # if nothing found
    #
    # @param [Fixnum] vmaddr virtual address
    # @return [Indis::Symbol, nil] resolved symbol or nil if none found
    def resolve_symbol_at_address(vmaddr)
      s = @symbols.find { |sym| sym.vmaddr == vmaddr }
      return s if s
      return @format.resolve_symbol_at_address(vmaddr) if @format.respond_to?(:resolve_symbol_at_address)
    end
    
    private
    def enqueue_event(event, args)
      @event_queue ||= []
      @event_queue << [event, args]
    end
    
    def replay_queue
      return unless @event_queue
      @event_queue.each { |(e, args)| publish_event(e, *args) }
      @event_queue = nil
    end
    
    def subscriptions_array(event)
      @subscriptions ||= {}
      
      a = @subscriptions[event]
      unless a
        a = []
        @subscriptions[event] = a
      end
      a
    end
  end
  
end