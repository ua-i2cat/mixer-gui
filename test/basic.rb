require 'test/unit'
require 'json'
require '../mixer.rb'

class TestMixerBasic < Test::Unit::TestCase

  def setup
    @mixer = Mixer.new('localhost', 2222, testing = :request)
  end

  def teardown
    @mixer.exit
  end

  def test_start_request
    request = @mixer.start
    assert_equal("start_mixer", request[:action])
    assert_not_nil(request[:params][:width])
    assert_not_nil(request[:params][:height])
    assert_not_nil(request[:params][:max_streams])
    assert_not_nil(request[:params][:input_port])
  end

  def test_add_stream_request
    request = @mixer.add_stream(1024, 436)
    assert_equal("add_stream", request[:action])
    assert_equal(1024, request[:params][:width])
    assert_equal(436, request[:params][:height])
  end

  def test_remove_stream_request
    id = Random.rand(8)
    request = @mixer.remove_stream(id)
    assert_equal("remove_stream", request[:action])
    assert_equal(id, request[:params][:id])
  end

  def test_modify_stream_request
    id = Random.rand(8)
    request = @mixer.modify_stream(0, options = {
      :id => id,
      :width => 400,
      :height => 400,
      :x => 10,
      :y => 10,
      :layer => 1,
      :keep_aspect_ratio => true
      })
    assert_equal("modify_stream", request[:action])
    assert_equal(id, request[:params][:id])
    assert_equal(400, request[:params][:width])
    assert_equal(400, request[:params][:height])
    assert_equal(10, request[:params][:x])
    assert_equal(10, request[:params][:y])
    assert_equal(1, request[:params][:layer])
    assert_equal(true, request[:params][:keep_aspect_ratio])
  end

  def test_disable_stream_request
    id = Random.rand(8)
    request = @mixer.disable_stream(id)
    assert_equal("disable_stream", request[:action])
    assert_equal(id, request[:params][:id])
  end

  def test_enable_stream_request
    id = Random.rand(8)
    request = @mixer.enable_stream(id)
    assert_equal("enable_stream", request[:action])
    assert_equal(id, request[:params][:id])
  end

  def test_modify_layout_request
    request = @mixer.modify_layout(1200, 1000, false)
    assert_equal("modify_layout", request[:action])
    assert_equal(1200, request[:params][:width])
    assert_equal(1000, request[:params][:height])
    assert_equal(false, request[:params][:resize_streams])
  end

  def test_add_destination_request
    request = @mixer.add_destination("localhost", 8000)
    assert_equal("add_destination", request[:action])
    assert_equal("localhost", request[:params][:ip])
    assert_equal(8000, request[:params][:port])
  end

  def test_remove_destination_request
    id = Random.rand(8)
    request = @mixer.remove_destination(id)
    assert_equal("remove_destination", request[:action])
    assert_equal(id, request[:params][:id])
  end

  def test_stop_request
    request = @mixer.stop
    assert_equal("stop_mixer", request[:action])
  end

  def test_exit_request
    request = @mixer.exit
    assert_equal("exit_mixer", request[:action])
  end

  def test_get_streams_request
    request = @mixer.get_streams
    assert_equal("get_streams", request[:action])
  end

  def test_get_stream_request
    id = Random.rand(8)
    request = @mixer.get_stream(id)
    assert_equal("get_stream", request[:action])
    assert_equal(id, request[:params][:id])
  end

  def test_get_destinations_request
    request = @mixer.get_destinations
    assert_equal("get_destinations", request[:action])
  end

  def test_get_destination_request
    id = Random.rand(8)
    request = @mixer.get_destination(id)
    assert_equal("get_destination", request[:action])
    assert_equal(id, request[:params][:id])
  end

end 