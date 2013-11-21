#!/usr/bin/env ruby

require 'being'

class Player < Being
  def next_move dungeon, window
    cmd = window.getch
  end

  def show status_bar
    status_bar.clear
    status_bar << "Ha Ha, I'm a player"
  end
end
