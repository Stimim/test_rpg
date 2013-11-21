#!/usr/bin/env ruby

# any beings in the game should extend this class.
class Being
  def initialize
    @rounds_per_move = 10
    @nround = 0
  end

  def next_round dungeon, window
    @nround = @nround + 1
    if @nround == @rounds_per_move
      @nround = 0
      next_move dungeon, window
    end
  end

  def next_move dungeon, window
    # nothing
  end
end
