require 'socket'
require 'json'

a = TCPServer.new('', 4444) # '' means to bind to "all interfaces", same as nil or '0.0.0.0'

loop {
  client = a.accept
  request = JSON.parse(client.recv(1024))
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
  client.print({ :error => nil }.to_json)
  client.close
}