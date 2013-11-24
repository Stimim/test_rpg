#!/usr/bin/env ruby

require 'singleton'

class DungeonFeatures
  private_class_method :new

  def DungeonFeatures.create symbol, open_area=false, do_cmd=nil
    new(symbol, do_cmd, open_area)
  end

  def initialize symbol, do_cmd, open_area
    @symbol = symbol
    @do_cmd = do_cmd
    @open_area = open_area
  end

  def take_action who, game, display, cmd
    return @do_cmd.call(who, game, display, cmd) if @do_cmd.is_a? Proc
    return false
  end

  def draw window, x, y
    window.setpos(x, y)
    window << @symbol
  end

  def open_area?
    @open_area
  end

  public
  STAIR_UP = DungeonFeatures.create('<', true, lambda do |who, game, display, cmd|
    if cmd == ?<
      display.message.append "go upstair"
      return true
    end
    return false
  end)

  STAIR_DOWN = DungeonFeatures.create('>', true, lambda do |who, game, display, cmd|
    if cmd == ?>
      display.message.append "go downstair"
      return true
    end
    return false
  end)

  SPACE = DungeonFeatures.create('.', true)
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
    @beings = (1..24).collect do
      (1..80).collect do
        nil
      end
    end

    make_stair
  end

  def show window
    window.clear
    (0..23).each do |y|
      (0..79).each do |x|
        if @beings[y][x] != nil
          @beings[y][x].draw(window, y, x)
        elsif @piles[y][x] != nil
          @piles[y][x][-1].draw(window, y, x)
        elsif @cell[y][x] != nil
          @cell[y][x].draw(window, y, x)
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
              being.env = @cell[y][x]
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
        being.env = @cell[y][x]
        success = [x, y]
      end
    end
    return success
  end

  def move_to being, old_x, old_y, new_x, new_y
    # there is a monster!!!
    return @beings[new_y][new_x] if @beings[new_y][new_x] != nil

    # is there a way??
    if @cell[new_y][new_x] != nil and @cell[new_y][new_x].open_area?
      @beings[old_y][old_x] = nil
      @beings[new_y][new_x] = being
      being.env = @cell[new_y][new_x]
      return true
    end
    return false
  end

  private
  def make_stair
    (5..10).each do |y|
      (5..10).each do |x|
        @cell[y][x] = DungeonFeatures::SPACE
      end
    end
    @cell[5][5] = DungeonFeatures::STAIR_UP
    @cell[7][10] = DungeonFeatures::STAIR_DOWN
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

