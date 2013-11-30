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
    @monster = Human.new
    @player.gain_control
    @current_level.place @player
    @current_level.place @monster, [6, 6]
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
    @beings = [@player, @monster]

    while !over?
      @beings.each do |being|
        result = 0
        while result == 0
          result = being.next_round(self, @current_level, @display)
        end
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
