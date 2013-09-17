require 'socket'
require 'json'

require 'socket'
a = TCPServer.new('', 2000) # '' means to bind to "all interfaces", same as nil or '0.0.0.0'
loop {
  connection = a.accept
  puts "received:" + connection.recv(1024)
  connection.print({ :error => nil }.to_json)
  connection.close
}