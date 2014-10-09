#!/bin/env ruby
#
# Basic Button Test
# Uses GPIO for a red<->green toggle button
#
# Green LED is wired to pin 21
# Red LED is wired to pin 17
# Button is wired to pin 23
#
# By default, the Green LED is illuminated and
# when the button is pressed the the Red LED is
# illuminated and the Green LED is shut off
#
# When the button is released, the LED's toggle
# back to default state of Green on and Red off

# Load the lib path into the load_path
$:.unshift("../lib")

# Name the process in the proctable
$0 = "meatpi::basic_button_test"

# Let me know we're starting
puts "starting"

require 'meatpi'

# Setup ouput pin constants
RED   = PiPiper::Pin.new(:pin => 17, :direction => :out)
GREEN = PiPiper::Pin.new(:pin => 21, :direction => :out)

# Pin watchers
after :pin => 23, :goes => :high, :pull => :down  do
  puts "Button pressed"
  RED.on
  GREEN.off
end

after :pin => 23, :goes => :low do
  puts "Button released"
  RED.off
  GREEN.on
end

# Signal initialization is complete
4.times do
  RED.on
  GREEN.off
  sleep 0.1
  RED.off
  GREEN.on
  sleep 0.1
end

# Let me know we're up and running
puts "started"

# aaaaaand loop
PiPiper.wait
