#!/usr/bin/env ruby

require 'singleton'

class DungeonFeatures
  attr_reader :symbol

  private_class_method :new

  def DungeonFeatures.create symbol, do_cmd
    new(symbol, do_cmd)
  end

  def initialize symbol, do_cmd
    @symbol = symbol
    @do_cmd = do_cmd
  end

  def do_cmd cmd, game
    return @do_cmd.call(game, cmd) if @do_cmd.is_a? Proc
    return false
  end

  public
  STAIR_UP = DungeonFeatures.create('<', lambda do |game, cmd|
    if cmd == '<'
      game.show_message "go upstair"
      return true
    end
    return false
  end)

  STAIR_DOWN = DungeonFeatures.create('>', lambda do |game, cmd|
    if cmd == '>'
      game.show_message "go downstair"
      return true
    end
    return false
  end)

  SPACE = DungeonFeatures.create('.', nil)
end

class Level

  attr_reader :name

  def initialize name, options
    @name = name
    @cell = (1..24).collect do
      (1..80).collect do
        nil
      end
    end
    @piles = (1..24).collect do
      (1..80).collect do
        nil
      end
    end

    make_stair
  end

  def show window
    window.clear
    (0..23).each do |x|
      (0..79).each do |y|
        if @cell[x][y] != nil
          window.setpos(x, y)
          window << @cell[x][y].symbol
        end
      end
    end
  end

  private
  def make_stair
    (5..10).each do |x|
      (5..10).each do |y|
        @cell[x][y] = DungeonFeatures::SPACE
      end
    end
    @cell[5][5] = DungeonFeatures::STAIR_UP
    @cell[10][10] = DungeonFeatures::STAIR_DOWN
  end
end

class LevelFactory
  include Singleton
  @@levels = []

  def LevelFactory.load file
  end

  def LevelFactory.save file
  end

  def LevelFactory.get n, options=nil
    return @@levels[n] if @@levels[n] != nil
    @@levels[n] = Level.new("Dungeon Lv#{n}", options)
  end
end

