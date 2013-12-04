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

require 'rubygems'
require 'bundler/setup'

require 'liquid'
require 'sinatra/base'
require 'rmixer'

class MixerAPI < Sinatra::Base

  set :ip, '127.0.0.1'
  set :port, 7777
  set :mixer, RMixer::Mixer.new(settings.ip, settings.port)
  set :grid, 0
  set :output_grid, 0

  def error_json
    begin
      yield
    rescue RMixer::MixerError => e
      status 500
      { :error => e.message }.to_json
    rescue Errno::ECONNREFUSED => e
      status 500
      { :error => e.message }.to_json
    end
  end

  def error_html
    begin
      yield
    rescue Errno::ECONNREFUSED, RMixer::MixerError => e
      status 500
      halt liquid :error, :locals => { "message" => e.message }
    end
  end

  helpers do
    def started
      error_html do
        settings.mixer.get_state[:state] != 0
      end
    end
  end

  def dashboard
    k2s =
    lambda do |h|
      Hash === h ?
        Hash[
          h.map do |k, v|
            [k.respond_to?(:to_s) ? k.to_s : k, k2s[v]]
          end
        ] : h
    end

    if started
      
      #Input streams json parsing
      i_streams = settings.mixer.input_streams
      input_streams = []
      
      i_streams.each do |s|
        crops = []
        s[:crops].each do |c|
          crops << k2s[c]
        end
        s[:crops] = crops
        input_streams << k2s[s]
      end

      #Output stream json parsing
      o_stream = settings.mixer.output_stream
      output_stream = []
      o_crops = []

      o_stream[:crops].each do |c|
        dst = []
        c[:destinations].each do |d|
          dst << k2s[d]
        end
        c[:destinations] = dst
        o_crops << k2s[c]
      end

      o_stream[:crops] = o_crops
      output_stream << k2s[o_stream]

      liquid :index, :locals => {
        "input_streams" => input_streams,
        "output_streams" => output_stream,
        "grid" => settings.grid,
        "output_grid" => settings.output_grid
      }
    else
      liquid :before
    end
  end

  # Web App Methods

  get '/' do
    redirect '/app'
  end

  get '/app' do
    content_type :html
    dashboard
  end

  post '/app/start' do
    content_type :html
    error_html do
      settings.mixer.start(params)
    end
    redirect '/app'
  end

  post '/app/stop' do
    content_type :html
    error_html do
      settings.mixer.stop
    end
    settings.grid = 0
    settings.output_grid = 0
    redirect '/app'
  end

  post '/app/streams/add' do
    content_type :html
    error_html do
      settings.mixer.add_stream
      settings.mixer.set_grid(settings.grid)
    end
    redirect '/app'
  end

  post '/app/streams/:id/remove' do
    content_type :html
    error_html do
      settings.mixer.remove_stream(params[:id].to_i)
    end
    redirect '/app'
  end

  post '/app/streams/:id/crops/add' do
    content_type :html
    error_html do
      settings.mixer.add_crop_to_stream(
                        params[:id].to_i,
                        params[:c_w].to_i,
                        params[:c_h].to_i,
                        params[:c_x].to_i,
                        params[:c_y].to_i,
                        params[:dst_w].to_i,
                        params[:dst_h].to_i,
                        params[:dst_x].to_i,
                        params[:dst_y].to_i,
                        params[:layer].to_i
                    )
      settings.mixer.set_grid(settings.grid)
    end
    redirect '/app'
  end

  post '/app/streams/:id/crops/:c_id/modify' do
    content_type :html
    error_html do
      settings.mixer.modify_crop_from_stream(
                params[:id].to_i,
                params[:c_id].to_i,
                params[:c_w].to_i,
                params[:c_h].to_i,
                params[:c_x].to_i,
                params[:c_y].to_i
              )

      settings.mixer.modify_crop_resizing_from_stream(
                params[:id].to_i,
                params[:c_id].to_i,
                params[:dst_w].to_i,
                params[:dst_h].to_i,
                params[:dst_x].to_i,
                params[:dst_y].to_i,
                params[:layer].to_i
              )

      settings.mixer.set_grid(settings.grid)
    end
    redirect '/app'
  end

  post '/app/streams/:id/crops/:c_id/enable' do
    content_type :html
    error_html do
      settings.mixer.enable_crop_from_stream(params[:id].to_i, params[:c_id].to_i )
    end
    redirect '/app'
  end

  post '/app/streams/:id/crops/:c_id/disable' do
    content_type :html
    error_html do
      settings.mixer.disable_crop_from_stream(params[:id].to_i, params[:c_id].to_i )
    end
    redirect '/app'
  end

  post '/app/streams/:id/crops/:c_id/remove' do
    content_type :html
    error_html do
      settings.mixer.remove_crop_from_stream(params[:id].to_i, params[:c_id].to_i )
    end
    redirect '/app'
  end

  post '/app/output_stream/crops/add' do
    content_type :html
    error_html do
      settings.mixer.add_crop_to_layout(
                      params[:c_w].to_i,
                      params[:c_h].to_i,
                      params[:c_x].to_i,
                      params[:c_y].to_i,
                      params[:dst_w].to_i,
                      params[:dst_h].to_i
                    )
    end
    redirect '/app'
  end

  post '/app/output_stream/crops/:id/modify' do
    content_type :html
    error_html do
      settings.mixer.modify_crop_from_layout(
                      params[:id].to_i,
                      params[:c_w].to_i,
                      params[:c_h].to_i,
                      params[:c_x].to_i,
                      params[:c_y].to_i
                    )

      settings.mixer.modify_crop_resizing_from_layout(
                      params[:id].to_i,
                      params[:dst_w].to_i,
                      params[:dst_h].to_i,
                    )
    end
    redirect '/app'
  end

  post '/app/output_stream/crops/:id/destinations/add' do
    content_type :html
    error_html do
      settings.mixer.add_destination(params[:id].to_i, params[:ip], params[:port].to_i)
    end
    redirect '/app'
  end

  post '/app/output_stream/crops/:id/destinations/:d_id/remove' do
    content_type :html
    error_html do
      settings.mixer.remove_destination(params[:d_id].to_i)
    end
    redirect '/app'
  end

  post '/app/output_stream/crops/:id/remove' do
    content_type :html
    error_html do
      settings.mixer.remove_crop_from_layout(params[:id].to_i)
    end
    redirect '/app'
  end

  post '/app/grid' do
    content_type :html
    error_html do
      settings.mixer.set_grid(params[:id].to_i)
    end
    settings.grid = params[:id].to_i
    redirect '/app'
  end

  post '/app/output_grid' do
    content_type :html
    if settings.output_grid != 0
      redirect '/app'
    else
      error_html do
        settings.mixer.set_output_grid(params[:id].to_i)
      end
      settings.output_grid = params[:id].to_i
      redirect '/app'
    end
  end

  # JSON API Methods

  

  # JSON API Methods for MCU

  post '/streams/add_mcu' do
    content_type :json
    ret = []
    error_json do
      ret = settings.mixer.add_stream
      n = settings.mixer.input_streams.length
      case n
      when 0 .. 4
        settings.grid = 1 #2x2
      when 5 .. 6 
        settings.grid = 2 #3x2
      when 7 .. 9 
        settings.grid = 3 #3x3
      else
        raise MixerError, "Invalid grid id"
      end
    settings.mixer.set_grid(settings.grid)
    end
    return ret.to_json
  end

  post '/streams/:id/remove_mcu' do
    content_type :json
    error_json do
      settings.mixer.remove_stream(params[:id].to_i).to_json
      n = settings.mixer.input_streams.length
      case n
      when 0 .. 4
        settings.grid = 1 #2x2
      when 5 .. 6 
        settings.grid = 2 #3x2
      when 7 .. 9 
        settings.grid = 3 #3x3
      else
        raise MixerError, "Invalid grid id"
      end
      settings.mixer.set_grid(settings.grid)
    end
  end

  post '/output_stream/add_destination_mcu' do
    content_type :json
    error_json do
      o_stream = settings.mixer.output_stream
      id = o_stream[:crops].first[:id].to_i
      settings.mixer.add_destination(id, params[:ip], params[:port].to_i).to_json
    end
  end

  post '/output_stream/:id/remove_destination_mcu' do
    content_type :json
    error_json do
      settings.mixer.remove_destination(params[:id].to_i).to_json
    end
  end

end
