require 'socket'
require 'json'

class MockServer

  def initialize(host, port)
    @host = host
    @port = port
    @run = true
  end

  def respond(conn, error, data)
    response = {
      :error => error,
      :data => data
    }
    conn.print(response.to_json)
  end

  def start
    @thread = Thread.new do |t|
      a = TCPServer.new(@host, @port) # '' means to bind to "all interfaces", same as nil or '0.0.0.0'
      while @run
        client = a.accept
        request = JSON.parse(client.recv(1024))
        client.print({ :error => nil }.to_json)
        client.close
      end
      Thread.exit(@thread)
    end
  end

  def stop
    @run = false
  end

end