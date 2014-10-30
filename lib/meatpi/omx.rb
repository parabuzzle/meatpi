# a class for working with the omx player to play sounds for props
# this is a bit hacky at the moment because of the way OMX works
#
# someday, I would love to have a real omx implementation in pure ruby
# ... someday :-/
#
# Copyright (c) 2014 Zombie Nextdoor, Inc
# Mike Heijmans

require 'thread'
require 'singleton'

module MeatPi
  class Omx

    include Singleton

    attr_accessor :output, :player_thread, :mutex, :audio_path

    def play(file, opts={})
      stop!
      !file.match(/\//) ? audio_file = "#{@audio_path}/#{file}" : audio_file = file
      opts[:looping] ? loopit = '--loop' : loopit = ''
      mutex.synchronize {
        @player_thread = Thread.new { system("omxplayer -o #{@output} #{audio_file} #{loopit} > /dev/null") }
      }
    end

    def stop!
      mutex.synchronize {
        @player_thread.exit
        @player_thread.terminate
      }
      system('killall omxplayer.bin')
    end

    def status
      if `ps auxx | grep omxplayer.bin | grep -v grep | wc -l`.to_i > 0
        return :running
      else
        return :not_running
      end
    end

    private

    def initialize
      @output        = :local
      @audio_path    = "../audio"
      @player_thread = Thread.new {}
      @mutex         = Mutex.new
    end

  end
end
