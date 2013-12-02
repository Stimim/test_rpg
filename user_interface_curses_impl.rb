#!/usr/bin/env ruby

require 'singleton'
require 'curses'

require './user_interface.rb'
require './symbol.rb'
require './dungeon.rb'

class UserInterfaceCursesImpl < UserInterface
  include Singleton

  def initialize
    Curses::init_screen()

    Curses::noecho
    @level = Curses::Window.new Dungeon::NROW, Dungeon::NCOL, 2, 0
    @message = Curses::Window.new 1, 0, 0, 0
    @status_bar = Curses::Window.new 2, 0, (Dungeon::NROW + 2), 0
    @menu = Curses::Window.new 0, 0, 0, 0
    # @menu.attron Curses::A_INVIS
    @level.attrset Curses::A_NORMAL
  end

  def beep
    Curses::beep
  end

  def print_dungeon_symbol x, y, symbol
    # puts "print_dungeon_symbol #{x}, #{y}, #{symbol}"
    @level.setpos(y, x)
    @level.addch(UserInterfaceCursesImpl.symbol2char symbol)
    # @level.addch(?x)
  end

  def print_message msg
    return
  end

  def clear_message
    return
  end

  def flush
    @level.refresh
  end

  def getchar
    Curses::curs_set 1
    ch = @level.getch
    Curses::curs_set 0

    return ch
  end

  def set_current_pos x, y
    @level.setpos y, x
  end

  def self.symbol2char symbol
    case symbol
    when :BOULDER then return ?0
    when :HUMAN then return ?@
    when :STAIR_UP then return ?<
    when :STAIR_DOWN then return ?>
    when :GROUND then return ?.
    else ?!
    end
  end
end
