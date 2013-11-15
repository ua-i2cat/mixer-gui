# Rmixer

Mixer remote API Ruby implementation

## Installation

While developing:

    $ bundle install

To make it available system-wide:

    $ gem build rmixer.gemspec
    $ gem install rmixer-<version>.gem

To generate the documentation:

    $ rake rdoc

Or just `rake`, since `rdoc` is the default task.

## Usage

    require 'rmixer'

    m = RMixer::Mixer.new 'localhost', 7777
    m.start
    m.add_stream(1280, 720)
    m.streams
    # => [{ :id => 7, :width => 1280, :height => 720, ... }]
    m.destinations
    # => []
    m.add_destination('192.168.10.134', 5004)
    m.destinations
    # => [{ :id => 1, :ip => '192.168.10.134', :port => 5004}]
