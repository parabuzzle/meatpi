# Load the lib path into the load_path
$:.unshift("../lib")

require 'meatpi'

after :pin => 23, :goes => :high do
  puts "Button pressed"
  pin = PiPiper::Pin.new(:pin => 17, :direction => :out)
  pin.on
end

after :pin => 23, :goes => :low do
  puts "Button released"
  pin = PiPiper::Pin.new(:pin => 17, :direction => :out)
  pin.off
end

PiPiper.wait
