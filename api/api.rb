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
  mixer_request do
    m.start(params).to_json
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
    m.stream(params[:id]).to_json
  end
end

get '/destinations' do
  content_type :json
  mixer_request do
    m.destinations.to_json
  end
end

get '/destinations/:id' do
  content_type :json
  mixer_request do
    m.destination(params[:id]).to_json
  end
end