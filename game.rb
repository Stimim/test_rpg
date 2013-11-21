#!/usr/bin/env ruby

require 'level'
require 'display'
require 'player'

class Game
  private_class_method :new

  def Game.create file = nil
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
    @player = Player.new
    @display = Display.instance
    @round = 0
  end

  def loadGame file
  end

  def start
    @current_level.show @display.dungeon
    @player.show @display.status_bar
    @beings = [@player]

    while true
      @beings.each do |being|
        being.next_round @current_level, @display.dungeon
      end
      @round = @round + 1
    end
  end
end

Game.create().start
