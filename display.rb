#!/usr/bin/env ruby

require 'singleton'
require 'curses'
require 'level'

class Window < Curses::Window
end

class MessageWindow < Window
  MaxLine = 80
  def initialize
    super(1, 0, 0, 0)

    @lines = []
  end

  def append msg
    if @lines.size == MaxLine
      @lines.pop
    end
    @lines.unshift msg
    self.clear
    self.addstr @lines[0]
    self.refresh
  end

  def list_all
    self.resize(Curses::lines, Curses::cols)
    length = [Curses::lines - 1, 1].max
    index = 0

    while true
      self.clear
      self.addstr @lines[index...(index+length)].join("\n")
      self.addstr "\nNext Page '>' Previous Page '<' Quit 'q'"

      self.refresh

      case self.getch
      when ?>
        index += length
        break if index >= @lines.size
      when ?<
        index = [index - length, 0].max
      when ?q
        break
      end
    end

    self.clear
    self.refresh
    self.resize(1, Curses::cols)
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
    super(Level::MAX_Y, Level::MAX_X, 1, 0)

    @cache = Array.new(Level::MAX_Y) { Array.new(Level::MAX_X, nil) }
  end

  public
  def put(what, y, x)
    case what
    when DungeonFeature
      char = dungeon_feature_to_char what
    when Being
      char = being_to_char what
    else
      char = ??
    end

    #if @cache[y][x] != char
      self.setpos(y, x)
      self.addch(char)
      @cache[y][x] = char
    #end
  end

  private
  def dungeon_feature_to_char feature
    case feature
    when DungeonFeature::STAIR_UP then ?<
    when DungeonFeature::STAIR_DOWN then ?>
    when DungeonFeature::SPACE then ?.
    end
  end

  private
  def being_to_char being
    case being
    when Human then ?@
    else
      ?X
    end
  end
end

class StatusBar < Window
  def initialize
    super(2, 80, 21, 0)
  end
end

class Display
  include Singleton

  attr_reader :dungeon, :menu, :status_bar, :message

  def initialize
    Curses.init_screen()
    Curses.noecho
    Curses.curs_set 0
    @menu = MenuWindow.new
    @dungeon = DungeonWindow.new
    @status_bar = StatusBar.new
    @message = MessageWindow.new
  end
end
