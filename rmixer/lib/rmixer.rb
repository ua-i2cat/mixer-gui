require "rmixer/version"
require "connector"
require "grids"


module RMixer

  class MixerError < StandardError
  end

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
        when 1 #2x2
          calc_regular_grid(2,2)
          streams.zip(grid).each do |stream, grid|
            if grid.nil?
              disable_stream(stream[:id])
            elsif stream.nil?
            else
              modify_stream(
                stream[:id], 
                (grid[:width]*layout_size[:width]).floor, 
                (grid[:height]*layout_size[:height]).floor, 
                :x => (grid[:x]*layout_size[:width]).floor,
                :y => (grid[:y]*layout_size[:height]).floor
              )
            end
          end
        when 2 #3x2
        when 3 #3x3
        when 4 #upperleft
        when 5 #downright
        when 6 #lena
        else
          raise MixerError, "Invalid grid id"
        end
    end

    def method_missing(name, *args, &block)
      if @conn.respond_to?(name)
        response = @conn.send(name, *args, &block)
        raise MixerError, response[:error] if response[:error]
        #return nil if response.include?(:error) && response.size == 1
        return response
      else
        super
      end
    end

  end

end