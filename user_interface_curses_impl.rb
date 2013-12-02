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
    @level.setpos(y, x)
    @level.addch(UserInterfaceCursesImpl.symbol2char symbol)
  end

  def print_messages msgs
    @message.resize(Curses::lines, Curses::cols)
    index = 0
    length = [Curses::lines - 1, 1].max

    while true
      @message.clear
      @message.addstr msgs[index...(index + length)].join("\n")
      @message.addstr "\nNext Page '>' Previous Page '<' Quit 'q'"

      @message.refresh

      case @message.getch
      when ?>
        index += length
        break if index >= @lines.size
      when ?<
        index = [index - length, 0].max
      when ?q
        break
      end
    end

    @message.clear
    @message.refresh
    @message.resize(1, Curses::cols)
  end

  def print_message msg
    @message.clear
    @message.setpos 0, 0
    @message << msg
    @message.refresh
    return
  end

  def clear_message
    @message.clear
    @message.refresh
    return
  end

  def clear_level
    @level.clear
    @level.refresh
  end

  def flush_level
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
    when :NO_MEMORY then return ?\s
    else ?!
    end
  end
end
