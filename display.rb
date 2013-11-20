#!/usr/bin/env ruby

require 'singleton'
require 'curses'

class Window
  def initialize height, width, top, left
    @window = Curse::Window.new(height, width, top, left)
  end


end

class MessageWindow < Window
  def initialize
    super()
  end
end

class Display
  include Singleton

  attr_reader :dialogView, :mapView, :statusView

  def initialize
    Curses.init_screen()
    @dialogView = Curse::Window.new()
    @mapView = Curse::Window.new()
    @statusView = Curse::Window.new()
  end
end
