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

    def input_streams
      get_input_streams[:input_streams]
    end

    def output_stream
      get_output_stream[:output_stream]
    end

    def stats
      get_stats
    end

    def horitzontal(width, height, str_id, crop_id)
      layout_size = get_layout_size
      modify_crop_resizing_from_stream(str_id, crop_id, width, height, 0, 0, 10, 0)
      x = 0
      60.times do |d|
        x += 64
        if (x + width > layout_size[:width])
          x = 0
        end
        modify_crop_resizing_from_stream(str_id, crop_id, width, height, x, 0, 10, d)
      end
    end

    def slow_resizing(str_id, crop_id, width_percent, height_percent, seconds)
      layout_size = get_layout_size
      crop = get_crop_from_stream(str_id, crop_id)
      final_width = crop[:dst_w] * width_percent
      final_height = crop[:dst_h] * height_percent

      if final_width + crop[:dst_x] > layout_size[:width]
        final_width = layout_size[:width] - crop[:dst_x] 
      end

      if final_height + crop[:dst_y] > layout_size[:height]
        final_height = layout_size[:height] - crop[:dst_y] 
      end

      it = seconds*10 #resize every 100 ms
      width = crop[:dst_w]
      height = crop[:dst_h]
      
      delta_w = ((final_width - width)/it).floor
      delta_h = ((final_height - height)/it).floor

      it.times do |d|
        width += delta_w
        height += delta_h
        modify_crop_resizing_from_stream(str_id, crop_id, width, height, crop[:dst_x], crop[:dst_y], 10, 1.0, d*100)
      end

    end

    def ping_pong(width, height, str_id, crop_id, step_x = 0.2, step_y = 0.1)
      layout_size = get_layout_size
      modify_crop_resizing_from_stream(str_id, crop_id, width, height, 0, 0, 10, 1.0, 0)
      lw = layout_size[:width]
      lh = layout_size[:height]
      x = rand(lw - width)
      y = rand(lh - height)
      vx = (step_x*lw).floor
      vy = (step_y*lh).floor
      200.times do |d|
        x += vx
        y += vy

        if x + width > lw
          x = lw - width
          vx = -vx
        elsif x < 0
          x = 0
          vx = -vx
        end

        if y + height > lh
          y = lh - height
          vy = -vy
        elsif y < 0
          y = 0
          vy = -vy
        end

        modify_crop_resizing_from_stream(str_id, crop_id, width, height, x, y, 10, 1.0, d*100)
      end
    end

    def set_grid(id)
      layout_size = get_layout_size
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

      crops = []
      input_streams.each do |s|
        s[:crops].each do |c|
          c[:str_id] = s[:id]
          crops << c
        end
      end

      crops.zip(grid).each do |c, g|
        if g.nil?
          disable_crop_from_stream(c[:str_id], c[:id])
        elsif c.nil?
        else
          modify_crop_resizing_from_stream(
            c[:str_id],
            c[:id], 
            (g[:width]*layout_size[:width]).floor, 
            (g[:height]*layout_size[:height]).floor,
            (g[:x]*layout_size[:width]).floor, 
            (g[:y]*layout_size[:height]).floor,
            g[:layer],
            c[:opacity]
          )
          #enable_crop_from_stream(c[:str_id], c[:id])
        end
      end

      return nil
    end

    def set_output_grid(id)
      layout_size = get_layout_size
      grid = case id
      when 0
        return
      when 1 #2x2
        calc_regular_grid(2,2)
      else
        raise MixerError, "Invalid grid id"
      end

      grid.each do |g|
        add_crop_to_layout(
          (g[:width]*layout_size[:width]).floor, 
          (g[:height]*layout_size[:height]).floor,
          (g[:x]*layout_size[:width]).floor, 
          (g[:y]*layout_size[:height]).floor,
          (g[:width]*layout_size[:width]).floor, 
          (g[:height]*layout_size[:height]).floor, 
        )
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
