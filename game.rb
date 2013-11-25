#!/usr/bin/env ruby

require 'level'
require 'display'
require 'human'

class Game
  private_class_method :new

  attr_reader :display

  def self.create file = nil
    game = new
    if file != nil
      game.loadGame file
    else
      game.newGame
    end
    return game
  end

  def newGame
    @factory = LevelFactory.instance
    @current_level = LevelFactory.get 0
    @player = Human.new
    @player.gain_control
    @current_level.place @player
    if @player.cor_x == nil or @player.cor_y == nil
      return
    end
    @display = Display.instance
    @round = 0
  end

  def loadGame file
  end

  def start
    @current_level.show @display.dungeon
    @player.show @display.status_bar
    @beings = [@player]

    while !over?
      @beings.each do |being|
        being.next_round(self, @current_level, @display)
      end
      @round = @round + 1
      @current_level.show @display.dungeon
    end
  end

  def over
    @over = true
  end

  def over?
    @over
  end
end

Game.create().start
