#!/usr/bin/env ruby

require './provider.rb'
require './human.rb'

class Game
  include Singleton

  public
  def initialize
    @over = false
    @player = Provider.get_player
    @dungeon = Provider.get_dungeon
    @monsters = []
  end

  public
  def new_game
    @round = 0

    human = Human.new

    @player.add_member human

    @dungeon.enter_level 0

    # @dungeon.create_monster
  end

  public
  def over?
    @over
  end

  public
  def alive?
    not @over
  end

  public
  def over
    @over = true
  end

  # TODO implement this
  public
  def load_game filename
  end

  public
  def game_loop
    while true
      @round = @round + 1

      # monsters under player's control always move first
      @player.each_member do |m|
        m.tick
      end

      @monsters.each do |m|
        m.tick
      end
    end
  end
end

Provider.get_game.new_game
Provider.get_game.game_loop

