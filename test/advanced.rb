require 'test/unit'
require 'json'
require '../mixer.rb'

class MockServer

  def start
    @thread = Thread.new do |t|
      a = TCPServer.new('', 2222) # '' means to bind to "all interfaces", same as nil or '0.0.0.0'
      loop {
        connection = a.accept
        puts "received:" + connection.recv(1024)
        connection.print({ :error => nil }.to_json)
        connection.close
      }
    end
  end

  def stop
    Thread.kill(@thread)
  end

end

class TestMixerAdvanced < Test::Unit::TestCase

  def setup
    @server = MockServer.new
    @server.start
    @mixer = Mixer.new('localhost', 2222)
  end

  def teardown
    @server.stop
  end

  def test_basic
    assert_equal(true, @mixer.get_stream(0))
  end



end