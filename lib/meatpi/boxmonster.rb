# A class for working with the Monster-in-a-Box prop
#
# Copyright (c) 2014 Zombie Nextdoor, Inc
# Mike Heijmans

require 'thread'

module MeatPi
  class BoxMonster
    attr_accessor :relay_pin, :mutex, :status, :invert, :omx

    @@instance = false

    # This is a bastardization of the singleton pattern
    # You _can_ still call MeatPi::BoxMonster.new
    # But you should never call #new or you will replace the instance object (bad idea)
    # You SHOULD call #instance instead (instance can take the arguments for relay_pin and invert)
    #
    # If we use the defacto singleton we couldn't configure it passing arguements
    # and would have to configure it after calling the instance up
    #
    # I'm lazy so I just did it this way, don't try this at home kids...
    def self.instance(*args)
      if @@instance
        return @@instance
      else
        return self.new(*args)
      end
    end

    def initialize(relay_pin, invert=false)
      @relay_pin = relay_pin
      @invert    = invert
      @status    = 'sleeping'
      @mutex     = Mutex.new
      @omx       = MeatPi::Omx.instance
      @@instance = self
    end

    def awake!
      @mutex.synchronize {
        @status = 'awake'
        on
      }
      play_angry_sound
    end

    def sleep!
      @mutex.synchronize {
        @status = 'sleeping'
        self.off
      }
      play_snoring
    end

    def angry_monster_routine
      awake!
      begin
        while @status == 'awake' do
          self.on
          sleep rand(0.5..4.0)
          self.off
          sleep rand(0.5..4.0)
        end
      ensure
        sleep!
      end
    end

    def self.shutdown
      self.instance.sleep!
    end

    def on
      if invert
        @relay_pin.off
      else
        @relay_pin.on
      end
    end

    def off
      if invert
        @relay_pin.on
      else
        @relay_pin.off
      end
    end

    def play_snoring
      @omx.stop!
      @omx.play('monster_wind_down.mp3')
      sleep 7
      @omx.play('monster_snoring.mp3', looping: true)
    end

    def play_angry_sound
      @omx.stop!
      @omx.play('monster_angry.mp3', looping: true)
    end

  end
end
