require 'test/unit'
require 'json'
require '../mixer/connector'
require './server'


class TestConnectorAdvanced < Test::Unit::TestCase

  def setup
    @server = MockServer.new("127.0.0.1", 2224)
    @server.start
    @connector = Mixer::Connector.new('localhost', 2224)
  end

  def teardown
    @server.stop
  end

  def test_basic
    assert_equal(true, @connector.get_stream(0))
  end

  def test_get_streams
    response = @connector.get_streams
    assert_false(response['error'])
  end

end