#
#  RUBYMIXER - A management ruby interface for MIXER 
#  Copyright (C) 2013  Fundació i2CAT, Internet i Innovació digital a Catalunya
#
#  This file is part of thin RUBYMIXER.
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#  Authors:  Marc Palau <marc.palau@i2cat.net>,
#            Ignacio Contreras <ignacio.contreras@i2cat.net>
#   

require "rmixer/version"
require "connector"
require "grids"


module RMixer

  # Generic error to be thrown when an error is returned by the remote
  # *Mixer* instance
  class MixerError < StandardError
  end

  # Proxy class that delegates most of it functions to a RMixer::Connector
  # instance while adding exception and convenience methods.
  class Mixer

    def initialize(host, port)
      @conn = RMixer::Connector.new(host, port)
    end

    def streams
      get_streams[:streams]
    end

    def stream(id)
      get_stream(id)
    end

    def destinations
      get_destinations[:destinations]
    end

    def destination(id)
      get_destination(id)
    end

    def set_grid(id)
      layout_size = get_layout
      grid = case id
      when 0
        return
      when 1 #2x2
        calc_regular_grid(2,2)
      when 2 #3x2
        calc_regular_grid(3,2)
      when 3 #3x3
        calc_regular_grid(3,3)
      when 4 #upperleft
        calc_upper_left_grid_6
      when 5 #downright
        calc_down_right_box
      when 6 #lena
      else
        raise MixerError, "Invalid grid id"
      end
        
      streams.zip(grid).each do |s, g|
        if g.nil?
          disable_stream(s[:id])
        elsif s.nil?
        else
          modify_stream(
            s[:id], 
            (g[:width]*layout_size[:width]).floor, 
            (g[:height]*layout_size[:height]).floor, 
            :x => (g[:x]*layout_size[:width]).floor,
            :y => (g[:y]*layout_size[:height]).floor,
            :layer => g[:layer]
          )
        end
      end
    end

    def method_missing(name, *args, &block)
      if @conn.respond_to?(name)
        begin
          response = @conn.send(name, *args, &block)
        rescue JSON::ParserError, Errno::ECONNREFUSED => e
          raise MixerError, e.message
        end
        raise MixerError, response[:error] if response[:error]
        #return nil if response.include?(:error) && response.size == 1
        return response
      else
        super
      end
    end

  end

end
