require 'socket'
require 'json'


module RMixer

  class Connector

    attr_reader :host, :port

    def initialize(host, port, testing = nil)
      @host = host
      @port = port
      @testing = testing
    end

    def start(options = {})
      params = {
        :width => options[:width] || 1280,
        :height => options[:height] || 720,
        :max_streams => options[:max_streams] || 8,
        :input_port => options[:input_port] || 5004
      }
      get_response("start_mixer", params)
    end

    def add_stream(width, height)
      params = {
        :width => width,
        :height => height
      }
      get_response("add_stream", params)
    end

    def remove_stream(id)
      params = {
        :id => id
      }
      get_response("remove_stream", params)
    end

    def modify_stream(id, width, height, options = {})
      params = {
        :id => id,
        :width => width,
        :height => height,
        :x => options[:x] || 0,
        :y => options[:y] || 0,
        :layer => options[:layer] || 0,
        :keep_aspect_ratio => options[:keep_aspect_ratio] || false
      }
      get_response("modify_stream", params)
    end

    def disable_stream(id)
      params = {
        :id => id
      }
      get_response("disable_stream", params)
    end

    def enable_stream(id)
      params = {
        :id => id
      }
      get_response("enable_stream", params)
    end

    def modify_layout(width, height, resize_streams = true)
      params = {
        :width => width,
        :height => height,
        :resize_streams => resize_streams
      }
      get_response("modify_layout", params)
    end

    def add_destination(ip, port)
      params = {
        :ip => ip,
        :port => port
      }
      get_response("add_destination", params)
    end

    def remove_destination(id)
      params = {
        :id => id
      }
      get_response("remove_destination", params)
    end

    def stop
      get_response("stop_mixer")
    end

    def exit
      result = get_response("exit_mixer")
      return result
    end

    def get_streams
      get_response("get_streams")
    end

    def get_stream(id)
      params = {
        :id => id
      }
      get_response("get_stream", params)
    end

    def get_destinations
      get_response("get_destinations")
    end

    def get_destination(id)
      params = {
        :id => id
      }
      get_response("get_destination", params)
    end

    private
    def get_response(action, params = nil)
      request = {
        :action => action,
        :params => params
      }
      return request if @testing == :request
      s = TCPSocket.open(@host, @port)
      s.print(request.to_json)
      response = s.recv(1024) # TODO: max_len ?
      s.close
      return JSON.parse(response, :symbolize_names => true)
    end

  end

end