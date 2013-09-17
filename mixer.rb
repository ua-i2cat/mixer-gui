require 'socket'
require 'json'

class Mixer

  attr_reader :host, :port

  def initialize(host, port, testing = false)
    @host = host
    @port = port
    @testing = testing
    @s = TCPSocket.open(host, port) unless @testing

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
    if @testing
      send_action("exit_mixer")
    else
      send_action("exit_mixer")
      @s.close
    end
  end

  def get_streams
    send_action("get_streams")
    # TODO
  end

  def get_stream(id)
    params = {
      :id => id
    }
    send_action("get_stream", params)
  end

  def get_destinations
    send_action("get_destinations")
  end

  def get_destination(id)
    params = {
      :id => id
    }
    send_action("get_destination", params)
  end

  private
  def send_action(action, params = nil)
    request = {
      :action => action,
      :params => params
    }.to_json
    return request if @testing
    s.print(request)
  end

end