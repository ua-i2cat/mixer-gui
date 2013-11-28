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
        "grid" => settings.grid
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
                        params[:c_y].to_i
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

  # JSON API Methods

  post '/start' do
    content_type :json

    if params.include?(:size)
      width, height = options[:size].downcase.split('x')
      width = width.to_i
      height = height.to_i
    end

    options = {
      :width => width,
      :height => height,
      :max_streams => params[:max_streams].to_i,
      :input_port => params[:input_port].to_i
      }

    error_json do
      settings.mixer.start(params).to_json
    end
  end

  post '/streams/add' do
    content_type :json
    width, height = params[:size].downcase.split('x')
    width = width.to_i
    height = height.to_i
    options = {
      :new_w => (params[:new_w] || width).to_i,
      :new_h => (params[:new_h] || height).to_i,
      :x => (params[:x] || 0).to_i,
      :y => (params[:y] || 0).to_i,
      :layer => (params[:layer] || 1).to_i
    }
    error_json do
      settings.mixer.add_stream(width, height, options).to_json
    end
  end

  post '/streams/:id/remove' do
    content_type :json
    error_json do
      settings.mixer.remove_stream(params[:id].to_i).to_json
    end
  end

  get '/streams' do
    content_type :json
    error_json do
      settings.mixer.streams.to_json
    end
  end

  get '/streams/:id' do
    content_type :json
    error_json do
      settings.mixer.stream(params[:id].to_i).to_json
    end
  end

  post '/streams/:id/enable' do
    content_type :json
    error_json do
      settings.mixer.enable_stream(params[:id].to_i).to_json
      settings.mixer.set_grid(settings.grid).to_json
    end
  end

  post '/streams/:id/disable' do
    content_type :json
    error_json do
      settings.mixer.disable_stream(params[:id].to_i).to_json
    end
  end

  post '/streams/:id/modify' do
    content_type :json

    id = params[:id].to_i
    width = params[:width].to_i
    height = params[:height].to_i

    keep_text = params[:keep_aspect_ratio].downcase
    
    options = {
      :x => params[:x].to_i,
      :y => params[:y].to_i,
      :layer => params[:layer].to_i,
      :keep_aspect_ratio => (keep_text == "true" || keep_text == "1")
    }

    error_json do
      settings.mixer.modify_stream(id, width, height, options).to_json
    end
  end

  get '/destinations' do
    content_type :json
    error_json do
      settings.mixer.destinations.to_json
    end
  end

  post '/destinations/add' do
    content_type :json
    error_json do
      settings.mixer.add_destination(params[:ip], params[:port].to_i).to_json
    end
  end

  get '/destinations/:id' do
    content_type :json
    error_json do
      settings.mixer.destination(params[:id].to_i).to_json
    end
  end

  post '/destinations/:id/remove' do
    content_type :json
    error_json do
      settings.mixer.remove_destination(params[:id].to_i).to_json
    end
  end

  post '/grid' do
    content_type :json
    error_html do
      settings.mixer.set_grid(params[:id].to_i).to_json
    end
    settings.grid = params[:id].to_i
  end

  post '/stop' do
    content_type :json
    error_json do
      settings.mixer.stop.to_json
    end
  end

end
