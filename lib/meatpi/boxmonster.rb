# A class for working with the Monster-in-a-Box prop
require 'thread'

module MeatPi
  class BoxMonster
    attr_accessor :relay_pin, :mutex, :status, :invert

    @@instance = false

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
      @@instance = self
    end

    def awake!
      @mutex.synchronize {
        @status = 'awake'
        on
      }
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

    def sleep!
      @mutex.synchronize {
        @status = 'sleeping'
        self.off
      }
    end

    def self.shutdown
      self.instance.sleep!
    end

    def on
      if invert
        @relay_pin.off
      else
        #@relay_pin.on
        puts "ON!"
      end
    end

    def off
      if invert
        @relay_pin.on
      else
        #@relay_pin.off
        puts "OFF!"
      end
    end


  end
end
