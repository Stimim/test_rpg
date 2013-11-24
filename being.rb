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
    if @env == nil or !(@env.take_action self, game, display, cmd)
      display.message.append "no such command '#{cmd.chr}'"
    end
    return true
  end

  def control game, dungeon, display
    cmd = display.dungeon.getch
    take_action game, dungeon, display, cmd
  end
end
