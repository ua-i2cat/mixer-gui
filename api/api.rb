require 'sinatra'
#require '../rmixer/rmixer/mixer'

module RMixer

  class Mixer

    def initialize(host, port)
      @host = host
      @port = port
    end

    def start(options = {})
      
    end

  end

end


m = RMixer::Mixer.new 'localhost', 7777

post '/start' do
  m.start(params).to_s
end


