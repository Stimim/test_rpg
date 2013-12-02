#!/usr/bin/env ruby

require 'singleton'

require './provider.rb'
require './fixed_queue.rb'

# Collects the data of the player (not the creatures under control)
class Player
  include Singleton # one player per game

  MSG_QUE_SIZE = 80

  attr_reader :score

  def initialize
    @score = 0
    @team = []
    @memory = {}
    @msg_que = FixedQueue.new MSG_QUE_SIZE
  end

  def add_member m
    m.set_control true
    @team.push m
  end

  def each_member
    @team.each do |m|
      yield m
    end
  end

  # returns true if the player can see (x, y), currently, the player can see
  # what creatures under control can see.
  def can_see x, y
  end

  def enter_new_level level
    @memory[level] = Array.new(Dungeon::NROW) { Array.new(Dungeon::NCOL) }
  end

  def enter_level level, how
    @level = level
    if @memory[level] == nil
      enter_new_level level
    end

    @team.each do |m|
      m.enter_level level, how
    end

    update_vision
  end

  def update_vision
    @team.each do |m|
      gain_vision_from m
    end
    Provider.get_ui.flush
  end

  def gain_vision_at x, y
    # puts "#{x}, #{y}"
    symbol = Provider.get_dungeon.whats_there? x, y
    #puts "#{x}, #{y}, #{symbol}"
    if not symbol === @memory[@level][y][x]
      # puts "#{x}, #{y}, #{symbol}"
      @memory[@level][y][x] = symbol
      Provider.get_ui.print_dungeon_symbol x, y, symbol
    else
      # puts "false, #{symbol.id}, #{@memory[@level][y][x].id}"
    end
  end

  # now the player can see things this monster can see
  def gain_vision_from monster
    Provider.compute_field_of_view monster.cor_x, monster.cor_y, 80
  end

  def receive_message msg
    @msg_que.push msg
    Provider.get_ui.print_message msg
  end

  def show_messages
    Provider.get_ui.print_messages @msg_que
  end
end



