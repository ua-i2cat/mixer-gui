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

require 'socket'
require 'json'

module RMixer

  # ==== Overview
  # Class that allows the module to connect with a remote mixer instance and communicate
  # with it using, under the hood, the <b>Mixer JSON API</b>.
  #
  # ==== TCP Socket Usage
  # A RMixer::Connector instance creates a new TCP connection for each method.
  # This means that multiple instances of this class can be working at the
  # same time without blocking each other.
  #
  class Connector

    # Remote mixer host address
    attr_reader :host
    # Remote mixer port address
    attr_reader:port

    # Initializes a new RMixer::Connector instance.
    #
    # ==== Attributes
    #
    # * +host+ - Remote mixer host address
    # * +port+ - Remote mixer port address
    # * +testing+ - Optional testing parameter. If set to +:request+, changes
    #   the behaviour of RMixer::Connector#get_response
    #
    def initialize(host, port, testing = nil)
      @host = host
      @port = port
      @testing = testing
    end

    def start(options = {})
      width = options[:width].to_i
      height = options[:height].to_i
      params = {
        :width => (width != 0) ? width : 1280,
        :height => (height != 0) ? height : 720,
        :input_port => (options[:input_port] || 5004).to_i
      }
      get_response("start_mixer", params)
    end

    def add_stream
      get_response("add_stream")
    end

    def remove_stream(id)
      params = {
        :id => id.to_i
      }
      get_response("remove_stream", params)
    end

    def add_crop_to_stream(id, crop_width, crop_height, crop_x, crop_y, options = {})
      params = {
        :id => id.to_i,
        :crop_width => crop_width.to_i,
        :crop_height => crop_height.to_i,
        :crop_x => crop_x.to_i,
        :crop_y => crop_y.to_i,
        :layer => (options[:layer] || 1).to_i,
        :rsz_width => (options[:rsz_width] || crop_width).to_i,
        :rsz_height => (options[:rsz_height] || crop_height).to_i,
        :rsz_x => (options[:rsz_x] || x).to_i,
        :rsz_y => (options[:rsz_y] || y).to_i
      }
      get_response("add_crop_to_stream", params)
    end

    def modify_crop_from_stream(stream_id, crop_id, width, height, x, y)
      params = {
        :stream_id => stream_id.to_i,
        :crop_id => crop_id.to_i,
        :width => width.to_i,
        :height => height.to_i,
        :x => x.to_i,
        :y => y.to_i
      }
      get_response("modify_crop_from_stream", params)
    end

    def modify_crop_resizing_from_stream(stream_id, crop_id, width, height, x, y, layer = 1)
      params = {
        :stream_id => stream_id.to_i,
        :crop_id => crop_id.to_i,
        :width => width.to_i,
        :height => height.to_i,
        :x => x.to_i,
        :y => y.to_i,
        :layer => layer.to_i
      }
      get_response("modify_crop_resizing_from_stream", params)
    end

    def remove_crop_from_stream(stream_id, crop_id)
      params = {
        :stream_id => stream_id.to_i,
        :crop_id => crop_id.to_i
      }
      get_response("remove_crop_from_stream", params)
    end

    def add_crop_to_layout(width, height, x, y, output_width, output_height)
      params = {
        :width => width.to_i,
        :height => height.to_i,
        :x => x.to_i,
        :y => y.to_i,
        :output_width => output_width.to_i,
        :output_height => output_height.to_i
      }
      get_response("add_crop_to_layout", params)
    end

    def modify_crop_from_layout(crop_id, width, height, x, y)
      params = {
        :crop_id => crop_id.to_i,
        :width => width.to_i,
        :height => height.to_i,
        :x => x.to_i,
        :y => y.to_i
      }
      get_response("modify_crop_from_layout", params)
    end

    def modify_crop_resizing_from_layout(crop_id, width, height)
      params = {
        :crop_id => crop_id.to_i,
        :width => width.to_i,
        :height => height.to_i
      }
      get_response("modify_crop_resizing_from_layout", params)
    end

    def remove_crop_from_layout(crop_id)
      params = {
        :crop_id => crop_id.to_i
      }
      get_response("remove_crop_from_layout", params)
    end

    def enable_crop_from_stream(stream_id, crop_id)
      params = {
        :stream_id => stream_id.to_i,
        :crop_id => crop_id.to_i
      }
      get_response("enable_crop_from_stream", params)
    end

    def disable_crop_from_stream(stream_id, crop_id)
      params = {
        :stream_id => stream_id.to_i,
        :crop_id => crop_id.to_i
      }
      get_response("disable_crop_from_stream", params)
    end

    def disable_stream(id)
      params = {
        :id => id.to_i
      }
      get_response("disable_stream", params)
    end

    def enable_stream(id)
      params = {
        :id => id.to_i
      }
      get_response("enable_stream", params)
    end

    def add_destination(stream_id, ip, port)
      params = {
        :stream_id => stream_id.to_i,
        :ip => ip.to_s,
        :port => port.to_i
      }
      get_response("add_destination", params)
    end

    def remove_destination(id)
      params = {
        :id => id.to_i
      }
      get_response("remove_destination", params)
    end

    def stop
      get_response("stop_mixer")
    end

    def exit
      get_response("exit_mixer")
    end

    def get_streams
      get_response("get_streams")
    end

    def get_destinations
      get_response("get_destinations")
    end

    def get_destination(id)
      params = {
        :id => id.to_i
      }
      get_response("get_destination", params)
    end

    def get_layout
      get_response("get_layout")
    end

    def get_state
      get_response("get_state")
    end

    # Method that composes the JSON request and sends it over TCP to the
    # targetted remote mixer instance.
    #
    # Returns the Mixer's JSON response converted to a hash unless the
    # RMixer::Mixer was initialized with <tt>testing = :request</tt> option.
    #
    # ==== Testing 
    #
    # If <tt>@testing == :request</tt>, this method returns the hash that should
    # be sent over TCP without actually sending it.
    #
    # ==== Debugging
    #
    # This method is intended to be used internally, but is exposed since
    # it's useful for debugging.
    #
    # ==== Attributes
    # 
    # * +action+ - The action to be sent
    # * +params+ - Optional hash containing the parameters to be sent
    #
    # ==== Examples
    #   
    #   mixer = RMixer::Mixer.new "localhost", 7777
    #   mixer.get_response("start_mixer", { :width => 1280, :height => 720 })   
    #
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
