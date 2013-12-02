#!/usr/bin/env ruby

require './player.rb'
require './dungeon.rb'
require './user_interface_curses_impl.rb'
require './shadowcasting_field_of_view.rb'

module Provider
  def self.get_player
    Player.instance
  end

  def self.get_dungeon
    Dungeon.instance
  end

  def self.get_ui
    UserInterfaceCursesImpl.instance
  end

  def self.get_game
    Game.instance
  end

  def self.compute_field_of_view start_x, start_y, radius
    ShadowcastingFieldOfView.compute_field_of_view start_x, start_y, radius
  end
end
