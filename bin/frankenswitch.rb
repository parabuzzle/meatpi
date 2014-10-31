#!/bin/env ruby
#
# Franken-Switch
# Uses GPIO for a red<->green toggle and siren trigger
# for the haunted house crazy knife switch project
#
# Light Relay is wired to pin 24
# Siren Relay is wired to pin 23
# Moster Relay is wired to pin 18
# Button is wired to pin 25
#
# By default, the Green Light is illuminated and
# when the button is activated the the Red Light is
# illuminated and the Green Light is shut off
# and the siren chirps a few times
#
# When the button is released, the lights toggle
# back to default state of Green on and Red off
#
# NOTE: The Sainsmart 4 Channel Relay Board uses
#       Logic Low to consider a relay "active"
#       This can be confusing at best
#
# copyright (c) 2014 Mike Heijmans

# Load the lib path into the load_path
$:.unshift("../lib")

# Name the process in the proctable
$0 = "meatpi::frankenswitch"

# Let me know we're starting
puts "starting"

require 'meatpi'

# Setup ouput pin constants
LIGHT_RELAY        = PiPiper::Pin.new(:pin => 24, :direction => :out)
SIREN_RELAY        = PiPiper::Pin.new(:pin => 23, :direction => :out)
MONSTER_RELAY      = PiPiper::Pin.new(:pin => 18, :direction => :out)
SWITCH_PIN         = 25

# Pull the relay pins up because of the way the Sainsmart relay boards work
LIGHT_RELAY.on
SIREN_RELAY.on
MONSTER_RELAY.on

# We need a thread array to keep our threads for later graceful shutdown
threads = []
# We also need to set the running state for handling graceful shutdown later
@running = true

# Siren routine (run this in a thread to prevent blocking of main thread)
def sirenate!
  2.times do
    SIREN_RELAY.off
    sleep 0.5
    SIREN_RELAY.on
    sleep 0.25
  end
end

monster = MeatPi::BoxMonster.instance(MONSTER_RELAY, true)
$monster = Thread.new {}

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
  LIGHT_RELAY.on
  SIREN_RELAY.on
  MONSTER_RELAY.on

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

# Pin watchers
threads << after(:pin => SWITCH_PIN, :goes => :high, :pull => :down) do
  puts 'switch activated!'
  LIGHT_RELAY.off
  Thread.new { sirenate! }
  $monster.exit # Always exit the monster first!
  $monster = Thread.new { monster.angry_monster_routine }
end

threads << after(:pin => SWITCH_PIN, :goes => :low, :pull => :down) do
  puts "switch released!"
  monster.exit # Always exit the monster first!
  monster.sleep!
  LIGHT_RELAY.on
end

# Signal initialization is complete
3.times do
  LIGHT_RELAY.off
  sleep 0.5
  LIGHT_RELAY.on
  sleep 0.5
end

monster.sleep!

# Let me know we're up and running
puts "started"

# aaaaaand loop
while @running do
  sleep 0.1
end

exit 0
