#!/usr/bin/env ruby

require 'singleton'
require './boulder.rb'

class DungeonFeature
  private_class_method :new

  def DungeonFeature.create symbol, open_area=false, do_cmd=nil
    new(symbol, open_area, do_cmd)
  end

  def initialize symbol, open_area=false, do_cmd=nil
    @symbol = symbol
    @do_cmd = do_cmd
    @open_area = open_area
  end

  def take_action who, cmd
    return @do_cmd.call(who, cmd) if @do_cmd.is_a? Proc
    return 0
  end

  def open_area?
    @open_area
  end

  def symbol
    @symbol
  end

  public
  STAIR_UP = self.create(:STAIR_UP, true, lambda do |who, cmd|
    if cmd == ?<
      Provider.get_player.receive_message "go upstair"
      return 10
    end
    return 0
  end)

  STAIR_DOWN = self.create(:STAIR_DOWN, true, lambda do |who, cmd|
    if cmd == ?>
      Provider.get_player.receive_message "go downstair"
      return 10
    end
    return 0
  end)

  SPACE = self.create(:GROUND, true)
end

class Level
  def initialize
    @cell = Array.new(Dungeon::NROW) { Array.new(Dungeon::NCOL,
                                                 DungeonFeature::SPACE) }
    @pile = Array.new(Dungeon::NROW) { Array.new(Dungeon::NCOL) { Array.new } }
    @monster = Array.new(Dungeon::NROW) { Array.new(Dungeon::NCOL) }

    init_floor
    place_boulder
  end

  def init_floor
    @cell.each_index do |y|
      @cell[y].each_index do |x|
        @cell[y][x] = DungeonFeature::SPACE
      end
    end

    @uy = Kernel.rand(Dungeon::NROW)
    @ux = Kernel.rand(Dungeon::NCOL)

    begin
      @dy = Kernel.rand(Dungeon::NROW)
      @dx = Kernel.rand(Dungeon::NCOL)
    end while @dx == @ux and @dy == @uy

    #@uy = 5
    #@ux = 5
    #@dy = 8
    #@dx = 8
    @cell[@uy][@ux] = DungeonFeature::STAIR_UP
    @cell[@dy][@dx] = DungeonFeature::STAIR_DOWN
  end

  def place_boulder
    @cell.each_index do |y|
      @cell[y].each_index do |x|
        next if @cell[y][x] == DungeonFeature::STAIR_UP or @cell[y][x] == DungeonFeature::STAIR_DOWN

         if Kernel.rand < 0.01
           @pile[y][x].push Boulder.new
         end
      end
    end
  end


  # three possible way to enter this level
  #   :STAIR_UP     => appear at somewhere close to STAIR_DOWN
  #   :STAIR_DOWN   => appear at somewhere close to STAIR_UP
  #   :OTHER        => random place
  def add_monster who, how
    case how
    when :STAIR_UP
      who.move_to @dx, @dy
    when :STAIR_DOWN
      who.move_to @ux, @uy
    when :OTHER
      begin
        y = Kernel.rand(Dungeon::NROW)
        x = Kernel.rand(Dungeon::NCOL)
      end while not @pile[y][x].empty?
      who.move_to x, y
    end
  end

  def try_move_to who, nx, ny
    return false if not @cell[ny][nx].open_area?
    return @monster[ny][nx] if @monster[ny][nx] != nil
    @pile[ny][nx].each do |item|
      return false if item.blocks?
    end
    return true
  end

  # returns cost, nx', ny'
  def move_to who, ox, oy, nx, ny
    if oy != nil and ox != nil
      @monster[oy][ox] = nil
    end
    @monster[ny][nx] = who
    return 10, nx, ny
  end

  def whats_there? x, y
    return @monster[y][x].symbol if @monster[y][x] != nil
    return @pile[y][x][-1].symbol if not @pile[y][x].empty?
    return @cell[y][x].symbol
  end

  def blocked? x, y
    return true if @monster[y][x] != nil and @monster[y][x].blocks?
    return true if not @cell[y][x].open_area?

    @pile[y][x].each do |item|
      return true if item.blocks?
    end
    return false
  end

  def take_action who, cmd
    @cell[who.cor_y][who.cor_x].take_action who, cmd
  end
end

class Dungeon
  include Singleton

  NROW = 19
  NCOL = 79

  def initialize
    @levels = []
  end

  # TODO implement this
  def load_file filename
  end

  def enter_level n
    if @levels[n] == nil
      @levels[n] = Level.new
    end
    @current_level = @levels[n]
    Provider.get_player.enter_level @current_level, :STAIR_UP
  end

  def try_move_to who, nx, ny
    if in_range? nx, ny
      @current_level.try_move_to who, nx, ny
    else
      false
    end
  end

  # returns cost, nx', ny'
  def move_to who, ox, oy, nx, ny
    @current_level.move_to who, ox, oy, nx, ny
  end

  def blocked? x, y
    # puts "#{x}, #{y}"
    return true if not in_range? x, y
    @current_level.blocked? x, y
  end

  def whats_there? x, y
    # puts "#{x}, #{y}"
    return :GROUND if not in_range? x, y
    @current_level.whats_there? x, y
  end

  def take_action who, cmd
    @current_level.take_action who, cmd
  end

  def in_range? x, y
    return (0 <= y and y < NROW and 0 <= x and x < NCOL)
  end
end
