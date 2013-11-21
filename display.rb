#!/usr/bin/env ruby

require 'singleton'
require 'curses'

class Window < Curses::Window
end

class MessageWindow < Window
  def initialize
    super(0, 0, 0, 0)
  end
end

class MenuWindow < Window
  def initialize
    super(0, 30, 0, Curses::cols - 30)
  end

  def show items, indent=0, clear=false
    if clear
      self.clear
      self.setpos(0, 0)
    end

    if items.is_a? Hash
      items.each do |k, v|
        self << "#{' ' * indent}#{k}\n"
        self.show(v, indent + 1)
      end
    elsif items.is_a? Array
      items.each do |v|
        self.show(v, indent)
      end
    else
      self << "#{' ' * indent}#{items}\n"
    end
  end
end

class DungeonWindow < Window
  def initialize
    super(24, 80, 0, 0)
  end

  def put(char, x, y)
    self.setpos(x, y)
    self.addch(char)
  end
end

class StatusBar < Window
  def initialize
    super(2, 80, 25, 0)
  end
end

class Display
  include Singleton

  attr_reader :dungeon, :menu, :status_bar, :message

  def initialize
    Curses.init_screen()
    @menu = MenuWindow.new
    @dungeon = DungeonWindow.new
    @status_bar = StatusBar.new
    @message = MessageWindow.new
  end
end
