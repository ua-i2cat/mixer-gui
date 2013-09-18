require './connector'


module Mixer

  class MixerError < StandardError
  end

  class Mixer

    def initialize(host, port, options = {})
      @conn = Mixer::Connector(host, port)
      @conn.start(options)
    end

    def streams
      get_data(:get_streams)
    end

    def destinations
      get_data(:get_destinations)
    end

    private
    def get_data(message)
      response = @conn.send(message)
      raise MixerError if response[:error]
      return response[:data]
    end

  end

end