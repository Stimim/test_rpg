#!/usr/bin/env ruby

require 'singleton'

class Game
  private :new

  def Game.newGame
  end

  def Game.loadGame
  end
end

class LevelFactory
  @@levels = []

  def LevelFactory.load file
  end

  def LevelFactory.save file
  end

  def LevelFactory.get n, options
    return @@levels[n] if @@levels[n] != nil
  end
end
