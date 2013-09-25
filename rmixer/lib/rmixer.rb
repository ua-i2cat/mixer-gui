require "rmixer/version"
require "connector"


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

    def method_missing(name, *args, &block)
      if @conn.respond_to?(name)
        response = @conn.send(name, *args, &block)
        raise MixerError, response[:error] if response[:error]
        return nil if response.include?(:error) && response.size == 1
        return response
      end
    end

  end

end