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

def calc_regular_grid (cells_x = 2, cells_y = 2)

  grid = []
  width = 1.0/cells_x
  height = 1.0/cells_y
  cells_y.times do |i|
    cells_x.times do |j|
      grid << {
        :width => width,
        :height => height,
        :x => j * (1.0/cells_x),
        :y => i * (1.0/cells_y),
        :layer => 0
      }
    end
  end

return grid

end

def calc_upper_left_grid_6 (up_left_width = 0.75, up_left_height = 0.75)

  grid = []
  up_right_width = 1.0 - up_left_width
  up_right_height = up_left_height / 2
  down_left_width = up_left_width / 2
  down_left_height = 1.0 - up_left_height
  down_right_width = up_right_width
  down_right_height = down_left_height
  grid << {
    :width => up_left_width,
    :height => up_left_height,
    :x => 0,
    :y => 0,
    :layer => 0
  }

  2.times do |i|
    grid << {
      :width => up_right_width,
      :height => up_right_height,
      :x => up_left_width,
      :y => i * up_right_height,
      :layer => 0
    }
  end

  2.times do |i|
    grid << {
      :width => down_left_width,
      :height => down_left_height,
      :x => i * down_left_width,
      :y => up_left_height,
      :layer => 0
    }
  end

  grid << {
    :width => down_right_width,
    :height => down_right_height,
    :x => up_left_width,
    :y => up_left_height,
    :layer => 0
  }
  
  return grid

end

def calc_down_right_box (box_width = 0.25, box_height = 0.25)
  grid = []
  width = 1.0
  height = 1.0
  grid << {
    :width => width,
    :height => height,
    :x => 0,
    :y => 0,
    :layer => 0
  }

  grid << {
    :width => box_width,
    :height => box_height,
    :x => width - box_width,
    :y => height - box_height,
    :layer => 1
  }

end