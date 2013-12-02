#!/usr/bin/env ruby

require 'being'

class Human < ControllableBeing
  def self.name
    "human"
  end

  def take_action cmd
    case cmd
    when ?p
      # display.message.append "hahaha"
    else
      super cmd
    end
  end

  def draw window, x, y
    window.setpos(x, y)
    window << "@"
  end

  def symbol
    :HUMAN
  end
end
