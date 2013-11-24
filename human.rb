#!/usr/bin/env ruby

require 'being'

class Human < ControllableBeing
  def take_action game, dungeon, display, cmd
    case cmd
    when ?p
      display.message.append "hahaha"
    else
      super game, dungeon, display, cmd
    end
  end

  def show status_bar
    status_bar.clear
    status_bar << "Ha Ha, I'm a player"
  end

  def draw window, x, y
    window.setpos(x, y)
    window << "@"
  end
end
