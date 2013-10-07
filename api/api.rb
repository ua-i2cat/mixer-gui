require 'rubygems'
require 'bundler/setup'

require 'liquid'
require 'sinatra/base'
require 'rmixer'

class MixerAPI < Sinatra::Base

  set :mixer, RMixer::Mixer.new('192.168.10.219', 7777)
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
      streams = []
      destinations = []
      
      error_html do
        settings.mixer.streams.each do |s|
          streams << k2s[s]
        end
        settings.mixer.destinations.each do |d|
          destinations << k2s[d]
        end
      end

      liquid :index, :locals => {
        "streams" => streams,
        "destinations" => destinations,
        "grid" => settings.grid
      }
    else
      liquid :before
    end
  end

  # Web App Methods

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

  post '/app/streams/:id/disable' do
    content_type :html
    error_html do
      settings.mixer.disable_stream(params[:id].to_i)
    end
    redirect '/app'
  end

  post '/app/streams/:id/enable' do
    content_type :html
    error_html do
      settings.mixer.enable_stream(params[:id].to_i)
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

  post '/app/streams/add' do
    content_type :html
    if params[:size]
      width, height = params[:size].downcase.split('x')
    else
      width = params[:width]
      height = params[:height]
    end      
    width = width.to_i
    height = height.to_i

    options = {
      :new_w => (params[:new_w] || width).to_i,
      :new_h => (params[:new_h] || height).to_i,
      :x => (params[:x] || 0).to_i,
      :y => (params[:y] || 0).to_i,
      :layer => (params[:layer] || 1).to_i
    }
    error_html do
      settings.mixer.add_stream(width, height, options)
      settings.mixer.set_grid(settings.grid)
    end
    redirect '/app'
  end

  post '/app/destinations/add' do
    content_type :html
    error_html do
      settings.mixer.add_destination(params[:ip], params[:port].to_i)
    end
    redirect '/app'
  end

  post '/app/destinations/:id/remove' do
    content_type :html
    error_html do
      settings.mixer.remove_destination(params[:id].to_i)
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