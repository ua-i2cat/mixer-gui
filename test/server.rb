require 'socket'
require 'json'

class MockServer

  def initialize(host, port)
    @host = host
    @port = port
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
      a = TCPServer.new(host, port) # '' means to bind to "all interfaces", same as nil or '0.0.0.0'
      loop {
        connection = a.accept
        request = JSON.parse(connection.recv(1024))
        puts request
=begin        
        case request['action']
        when 'get_streams'
          respond(connection, nil, [
            {
              :id => 0,
              :width => 0,
              :height => 0
            },
            {
              :id => 1,
              :width => 1,
              :height => 1
            }
            ])
        else
          respond(connection, false, nil)
        end
=end
        connection.print({ :error => nil }.to_json)
        connection.close
      }
    end
  end

  def stop
    Thread.kill(@thread)
  end

end