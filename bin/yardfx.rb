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

#cleanup pins
[26, 19, 13, 6].each do |pin|
  File.open("/sys/class/gpio/unexport", "w") { |f| f.write("#{pin}") }
end

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
  # Thunder!
  OMX.play('thunder_crash.mp3', :overlap => true)

  # Lightning
  OUTPUTS[:r1].off
  sleep 0.55
  OUTPUTS[:r1].on

  # Wait for the audio to finish
  sleep 19

  # SCARY!
end

def storm
  sleep rand(20..50)
  lightning_crash!
end

def background_audio
  OMX.play('graveyard_background.mp3', :overlap => true, :looping => true)
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
OUTPUTS[:r1].off
sleep 2
OUTPUTS[:r1].on

# Start graveyard sounds here
threads << Thread.new { background_audio }

# Run a thread for random lighning crashes
threads << Thread.new {
  loop do
    storm
  end
}

# Let me know we're up and running
puts "started"

# aaaaaand loop
while @running do
  sleep 0.1
end

exit 0
