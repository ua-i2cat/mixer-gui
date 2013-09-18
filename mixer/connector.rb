require 'socket'
require 'json'


module Mixer

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
      send_action("start_mixer", params)
    end

    def add_stream(width, height)
      params = {
        :width => width,
        :height => height
      }
      send_action("add_stream", params)
    end

    def remove_stream(id)
      params = {
        :id => id
      }
      send_action("remove_stream", params)
    end

    def modify_stream(id, options = {})
      params = {
        :id => options[:id],
        :width => options[:width],
        :height => options[:height],
        :x => options[:x],
        :y => options[:y],
        :layer => options[:layer],
        :keep_aspect_ratio => options[:keep_aspect_ratio]
      }
      send_action("modify_stream", params)
    end

    def disable_stream(id)
      params = {
        :id => id
      }
      send_action("disable_stream", params)
    end

    def enable_stream(id)
      params = {
        :id => id
      }
      send_action("enable_stream", params)
    end

    def modify_layout(width, height, resize_streams = true)
      params = {
        :width => width,
        :height => height,
        :resize_streams => resize_streams
      }
      send_action("modify_layout", params)
    end

    def add_destination(ip, port)
      params = {
        :ip => ip,
        :port => port
      }
      send_action("add_destination", params)
    end

    def remove_destination(id)
      params = {
        :id => id
      }
      send_action("remove_destination", params)
    end

    def stop
      send_action("stop_mixer")
    end

    def exit
      return send_action("exit_mixer") if @testing
      send_action("exit_mixer")
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
    def send_action(action, params = nil)
      request = {
        :action => action,
        :params => params
      }
      return request if @testing == :request
      s = TCPSocket.open(@host, @port)
      s.print(request.to_json)
      s.close
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
      response = JSON.parse(s.recv(1024)) # TODO: max_len ?
      s.close
      return false if response['error']
      return true
    end

  end

end