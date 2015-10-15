#!/bin/env ruby
#
# YardFX
#
# NOTE: The Sainsmart 4 Channel Relay Board uses
#       Logic Low to consider a relay "active"
#       This can be confusing at best
#
# copyright (c) 2015 Mike Heijmans

# Load the lib path into the load_path
$:.unshift("../lib")

# Name the process in the proctable
$0 = "meatpi::yardfx"

# Let me know we're starting
puts "starting"

require 'meatpi'

# Setup ouput pin constants
OUTPUTS = {
  :r1 => PiPiper::Pin.new(:pin => 26, :direction => :out),
  :r2 => PiPiper::Pin.new(:pin => 19, :direction => :out),
  :r3 => PiPiper::Pin.new(:pin => 13, :direction => :out),
  :r4 => PiPiper::Pin.new(:pin => 6,  :direction => :out),
}

# Pull the relay pins up because of the way the Sainsmart relay boards work
OUTPUTS.each { |name, pin| pin.on}

# We need a thread array to keep our threads for later graceful shutdown
threads = []
# We also need to set the running state for handling graceful shutdown later
@running = true

OMX = MeatPi::Omx.instance

# lightning & Thunder routine (run this in a thread to prevent blocking of main thread)
def lightning_crash!

  # Lightning
  OUTPUTS[:r1].off
  sleep 0.55
  OUTPUTS[:r1].on

  # Thunder!
  sleep 0.5
  OMX.play('thunder_crash.mp3')

  # SCARY!
end

def background_audio

end

# Shutdown routine for killing everything off gracefully
def shutdown(threads)
  $monster.exit
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

  # finish up by turnning all relays on to set the relays to their default state
  OUTPUTS.each { |name, pin| pin.on}

  # signal shutdown of main loop
  @running = false
end

# Setup Signal Handling
Signal.trap("TERM") do
  puts "Terminating..."
  shutdown(threads)
end
Signal.trap("INT") do
  puts "Terminating..."
  shutdown(threads)
end

## Main Routine Logic

# Signal initialization is complete
3.times do
  OUTPUTS[:r1].off
  sleep 0.25
  OUTPUTS[:r1].on
  sleep 0.25
end

# Start graveyard sounds here


# Run a thread for random lighning crashes

# Let me know we're up and running
puts "started"

# aaaaaand loop
while @running do
  sleep 0.1
end

exit 0
