#!/bin/env ruby
#
# Franken-Switch
# Uses GPIO for a red<->green toggle and siren trigger
# for the haunted house crazy knife switch project
#
# Light Relay is wired to pin 17
# Siren Relay is wired to pin 21
# Button is wired to pin 23
#
# By default, the Green Light is illuminated and
# when the button is activated the the Red Light is
# illuminated and the Green Light is shut off
# and the siren chirps a few times
#
# When the button is released, the lights toggle
# back to default state of Green on and Red off

# Load the lib path into the load_path
$:.unshift("../lib")

# Name the process in the proctable
$0 = "meatpi::frankenswitch"

# Let me know we're starting
puts "starting"

require 'meatpi'

# Setup ouput pin constants
LIGHT_RELAY = PiPiper::Pin.new(:pin => 17, :direction => :out)
SIREN_RELAY = PiPiper::Pin.new(:pin => 21, :direction => :out)

# We need a thread array to keep our threads for later
threads = []

# Siren routine
def sirenate!
  # siren time
  stime = 1
  3.times do
    SIREN_RELAY.on
    sleep stime
    SIREN_RELAY.off
    sleep stime
  end
end

# Shutdown routine for killing everything off gracefully
def shutdown(threads)
  # exit each thread safely
  threads.each do |thread|
    thread.exit
  end

  # make sure our threads are shutdown
  running = true
  while running do
    running = false
    threads.each do |thread|
      if thread.status
        running = true
      end
    end
    sleep 0.1
  end

  # finish up by turnning all the pins off
  LIGHT_RELAY.off
  SIREN_RELAY.off

  # exit gracefully
  exit 0
end

# Pin watchers
threads << after :pin => 23, :goes => :high, :pull => :down do
  puts 'switch activated!'
  LIGHT_RELAY.on
  sirenate!
end

threads << after :pin => 23, :goes => :low do
  puts "switch released!"
  LIGHT_RELAY.off
end

# Signal initialization is complete
3.times do
  LIGHT_RELAY.on
  sleep 1
  LIGHT_RELAY.off
  sleep 1
end

# Let me know we're up and running
puts "started"

Signal.trap("TERM") do
  puts "Terminating..."
  shutdown(threads)
end

# aaaaaand loop
PiPiper.wait
