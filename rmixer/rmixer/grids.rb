=begin
GRIDS = [
  {
    :width => 0.5,
    :height => 0.5,
    :x => 0,
    :y = 0
  },
  {
    :width => 0.5,
    :height => 0.5,
    :x => 0.5,
    :y => 0
  }
]
=end

GRIDS = []
cells = 8
cells.times do |i|
   GRIDS << {
    :width => 2.0/cells,
    :height => 0.5,
    :x => 2.0/cells * 0.5 * i,
    :y => (i%2)*0.5
   }
end

puts GRIDS