#!/usr/bin/env ruby

require 'singleton'

class DungeonFeature
  private_class_method :new

  def DungeonFeature.create symbol, open_area=false, do_cmd=nil
    new(symbol, do_cmd, open_area)
  end

  def initialize symbol, do_cmd, open_area
    @symbol = symbol
    @do_cmd = do_cmd
    @open_area = open_area
  end

  def take_action who, game, display, cmd
    return @do_cmd.call(who, game, display, cmd) if @do_cmd.is_a? Proc
    return 0
  end

  def open_area?
    @open_area
  end

  public
  STAIR_UP = DungeonFeature.create('<', true, lambda do |who, game, display, cmd|
    if cmd == ?<
      display.message.append "go upstair"
      return 1
    end
    return 0
  end)

  STAIR_DOWN = DungeonFeature.create('>', true, lambda do |who, game, display, cmd|
    if cmd == ?>
      display.message.append "go downstair"
      return 1
    end
    return 0
  end)

  SPACE = DungeonFeature.create('.', true)
end

class Level
  attr_reader :name

  MAX_Y = 19
  MAX_X = 79
  def initialize name, options
    @name = name
    @cell = Array.new(MAX_Y) { Array.new(MAX_X, nil) }
    @piles = Array.new(MAX_Y) { Array.new(MAX_X, nil) }
    @beings = Array.new(MAX_Y) { Array.new(MAX_X, nil) }
    make_stair
    # @display = display
  end

  def show window
    # window.clear
    MAX_Y.times do |y|
      MAX_X.times do |x|
        if @beings[y][x] != nil
          window.put @beings[y][x], y, x
        elsif @piles[y][x] != nil
          window.put @piles[y][x][-1], y, x
        elsif @cell[y][x] != nil
          window.put @cell[y][x], y, x
        end
      end
    end
    window.refresh
  end

  def place being, place_option=nil
    success = false
    if place_option == nil
      catch (:done) do
        (5..10).each do |y|
          (5..10).each do |x|
            if @beings[y][x] == nil
              @beings[y][x] = being
              success = [x, y]
              throw :done
            end
          end
        end
      end
    elsif place_option.is_a? Array
      x = place_option[0]
      y = place_option[1]
      if @beings[y][x] == nil
        @beings[y][x] = being
        success = [x, y]
      end
    end
    x = success[0]
    y = success[1]
    being.set_location(self, x, y, @cell[y][x]) if success
    return success
  end

  def move_to being, old_x, old_y, new_x, new_y
    return false if new_x >= MAX_X or new_x < 0 or new_y >= MAX_Y or new_y < 0

    # there is a monster!!!
    return @beings[new_y][new_x] if @beings[new_y][new_x] != nil

    # is there a way??
    if @cell[new_y][new_x] != nil and @cell[new_y][new_x].open_area?
      @beings[old_y][old_x] = nil
      @beings[new_y][new_x] = being
      being.env = @cell[new_y][new_x]
      return @cell[new_y][new_x]
    end
    return false
  end

  private
  def make_stair
    MAX_Y.times do |y|
      MAX_X.times do |x|
        @cell[y][x] = DungeonFeature::SPACE
      end
    end
    @cell[5][5] = DungeonFeature::STAIR_UP
    @cell[7][10] = DungeonFeature::STAIR_DOWN
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

