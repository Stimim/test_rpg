#!/usr/bin/env ruby

# any beings in the game should extend this class.
class Being
  attr_writer :env
  attr_accessor :cor_x
  attr_accessor :cor_y

  def initialize
    @rounds_per_move = 10
    @nround = 0
    @env = nil
    @cor_x = nil
    @cor_y = nil
  end

  def next_round game, dungeon, display
    @nround = @nround + 1
    if @nround == @rounds_per_move
      @nround = 0
      next_move game, dungeon, display
    end
  end

  # returns true if action is done
  def next_move game, dungeon, display
    auto_move game, dungeon, display
  end

  def auto_move game, dungeon, display
    true
  end

  def place dungeon
    ret = dungeon.place self
    if ret
      @cor_x = ret[0]
      @cor_y = ret[1]
    end
    return ret
  end
end

class ControllableBeing < Being
  def next_move game, dungeon, display
    return control game, dungeon, display if controlled?
    auto_move game, dungeon, display
  end

  def controlled?
    @controlled
  end

  def gain_control
    @controlled = true
  end

  # cmd is an Fixnum, please implement this function.
  def take_action game, dungeon, display, cmd
    suc = false
    suc = (@env != nil and (@env.take_action self, game, display, cmd)) if !suc
    suc = (basic_action game, dungeon, display, cmd) if !suc
    display.message.append "no such command '#{cmd.chr}'" if !suc
    return true
  end

  def control game, dungeon, display
    cmd = display.dungeon.getch
    take_action game, dungeon, display, cmd
  end

  private
  def move_to dungeon, delta_x, delta_y
    if dungeon.move_to(self, cor_x, cor_y, cor_x + delta_x, cor_y + delta_y)
      @cor_x = cor_x + delta_x
      @cor_y = cor_y + delta_y
    else
      display.message.append "You can't go that way..."
    end
  end

  public
  def basic_action game, dungeon, display, cmd
    case cmd
    when ?Q
      display.message.append "Quit? [y/N]"
      answer = display.message.getch
      if answer == ?Y or answer == ?y
        game.over
      else
        display.message.append "Never mind."
      end
    when ?l then move_to dungeon, 1, 0
    when ?h then move_to dungeon, -1, 0
    when ?j then move_to dungeon, 0, 1
    when ?k then move_to dungeon, 0, -1
    when ?y then move_to dungeon, -1, -1
    when ?u then move_to dungeon, 1, -1
    when ?b then move_to dungeon, -1, 1
    when ?n then move_to dungeon, 1, 1
    when ?\C-p then display.message.list_all
    else
      return false
    end
    return true
  end
end
