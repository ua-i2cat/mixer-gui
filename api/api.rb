require 'sinatra'
require '../rmixer/rmixer/mixer'


m = RMixer::Mixer.new 'localhost', 7777

def mixer_request
  begin
    yield
  rescue RMixer::MixerError => e
    status 500
    { :error => e.message }.to_json
  end
end

post '/start' do
  content_type :json

  if params.include?(:size)
    width, height = options[:size].split('x').to_i
  end

  options = {
    :width => width,
    :height => height,
    :max_streams => params[:max_streams].to_i,
    :input_port => params[:input_port].to_i
    }

  mixer_request do
    m.start(params).to_json
  end
end

post '/streams/add' do
  content_type :json
  mixer_request do
    m.add_stream(params[:width].to_i, params[:height].to_i)
  end
end

post '/streams/:id/remove' do
  content_type :json
  mixer_request do
    m.remove_stream(params[:id].to_i)
  end
end


get '/streams' do
  content_type :json
  mixer_request do
    m.streams.to_json
  end
end

get '/streams/:id' do
  content_type :json
  mixer_request do
    m.stream(params[:id].to_i).to_json
  end
end

post '/streams/:id/modify' do
  content_type :json

  id = params[:id].to_i
  width = params[:width].to_i
  height = params[:height].to_i

  options = {
    :x => params[:x].to_i,
    :y => params[:y].to_i,
    :layer => params[:layer].to_i,
    :keep_text => params[:keep_aspect_ratio].downcase,
    :keep_aspect_ratio => true if keep_text == "true" || keep_text == "1"
                        else false
  }

  mixer_request do
    m.modify_stream(id, width, height, options).to_json
  end
end

get '/destinations' do
  content_type :json
  mixer_request do
    m.destinations.to_json
  end
end

post '/destinations/add' do
  content_type :json
  mixer_request do
    m.add_destination(params[:ip], params[:port].to_i).to_json
  end
end

get '/destinations/:id' do
  content_type :json
  mixer_request do
    m.destination(params[:id].to_i).to_json
  end
end

post '/destinations/:id/remove' do
  content_type :json
  mixer_request do
    m.remove_destination(params[:id].to_i)
  end
end