#!/usr/bin/env ruby

require 'being'

class Human < ControllableBeing
  def take_action game, dungeon, display, cmd
    case cmd
    when ?Q
      display.message.append "Quit? [y/N]"
      answer = display.message.getch
      if answer == ?Y or answer == ?y
        game.over 
      else
        display.message.append "Never mind."
      end
    when ?l # go east
      if dungeon.move_to(self, cor_x, cor_y, cor_x + 1, cor_y)
        @cor_x = cor_x + 1
      else
        display.message.append "You can't go that way..."
      end
    when ?h # go west
      if dungeon.move_to(self, cor_x, cor_y, cor_x - 1, cor_y)
        @cor_x = cor_x - 1
      else
        display.message.append "You can't go that way..."
      end
    when ?j # go south
      if dungeon.move_to(self, cor_x, cor_y, cor_x, cor_y + 1)
        @cor_y = cor_y + 1
      else
        display.message.append "You can't go that way..."
      end
    when ?k # go north
      if dungeon.move_to(self, cor_x, cor_y, cor_x, cor_y - 1)
        @cor_y = cor_y - 1
      else
        display.message.append "You can't go that way..."
      end
    when ?\C-p
      display.message.list_all
    else
      super game, dungeon, display, cmd
    end

    display.dungeon.setpos(5, 5)
  end

  def show status_bar
    status_bar.clear
    status_bar << "Ha Ha, I'm a player"
  end

  def draw window, x, y
    window.setpos(x, y)
    window << "@"
  end
end
