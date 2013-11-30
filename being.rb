#!/usr/bin/env ruby

# any beings in the game should extend this class.
class Being
  attr_writer :env
  attr_accessor :cor_x
  attr_accessor :cor_y

  def self.name
    "monster"
  end

  def initialize
    @rounds_per_move = 10
    @nround = 0
    @env = nil
    @cor_x = nil
    @cor_y = nil
    @dungeon = nil
    @max_hp = 100
    @eff_hp = @max_hp
    @tmp_hp = @max_hp
  end

  public
  def receive_damage minor, major
    @tmp_hp -= minor
    @eff_hp -= major

    return die if @eff_hp <= 0
    return faint if @tmp_hp <= 0
    return
  end

  public
  def next_round game, dungeon, display
    @nround = @nround + 1
    if @nround == @rounds_per_move
      @nround = 0
      next_move game, dungeon, display
    end
  end

  # returns 0 if nothing is done,
  # returns a positive value indicates number of rounds taken.
  # returns -1 if this action ends the game
  # returns -2 if this action failed but is consumed
  private
  def next_move game, dungeon, display
    auto_move game, dungeon, display
  end

  private
  def auto_move game, dungeon, display
    1
  end

  # set where I am
  public
  def set_location dungeon, x, y, env
    @dungeon = dungeon
    @cor_x = x
    @cor_y = y
    @env = env
  end

  public
  def die
  end

  # returns "a #{monster name}" or "an #{monster name}"
  public
  def a_name
    return "a #{self.class.name}"
  end

  # returns "the #{monster name}"
  public
  def the_name
    return "the #{self.class.name}"
  end
end

class ControllableBeing < Being
  attr_reader :nickname

  def initialize
    super
    @nickname = "stimim"
  end

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

  def lose_control
    @controlled = false
  end

  # returns 0 if nothing is done,
  # returns a positive value indicates number of rounds taken.
  # returns -1 if this action ends the game
  #
  # cmd is an Fixnum, represents the key user pressed.
  public
  def take_action game, dungeon, display, cmd
    suc = 0
    suc = (@env != nil and (@env.take_action self, game, display, cmd)) if suc == 0
    suc = (basic_action game, dungeon, display, cmd) if suc == 0
    display.message.append "no such command '#{cmd.chr}'" if suc == 0
    return suc
  end

  # returns 0 if nothing is done,
  # returns a positive value indicates number of rounds taken.
  # returns -1 if this action ends the game
  public
  def control game, dungeon, display
    self.show_status display.status_bar
    cmd = display.dungeon.getch
    display.message.clear
    display.message.refresh
    result = take_action game, dungeon, display, cmd
    return result
  end

  private
  def move_to dungeon, display, delta_x, delta_y
    result = dungeon.move_to(self, cor_x, cor_y, cor_x + delta_x, cor_y + delta_y)
    if result.is_a? DungeonFeature
      @cor_x = cor_x + delta_x
      @cor_y = cor_y + delta_y
      @env = result
    elsif result.is_a? Being
      # there is a monster!!!
      display.message.append "There is #{result.a_name}"
      return -2
    else
      display.message.append "You can't go that way..."
      return -2
    end
  end

  public
  def basic_action game, dungeon, display, cmd
    result = 0
    case cmd
    when ?Q
      result = -1
      display.message.append "Quit? [y/N]"
      answer = display.message.getch
      if answer == ?Y or answer == ?y
        game.over
      else
        display.message.append "Never mind."
      end
    when ?l then result = move_to dungeon, display, 1, 0
    when ?h then result = move_to dungeon, display, -1, 0
    when ?j then result = move_to dungeon, display, 0, 1
    when ?k then result = move_to dungeon, display, 0, -1
    when ?y then result = move_to dungeon, display, -1, -1
    when ?u then result = move_to dungeon, display, 1, -1
    when ?b then result = move_to dungeon, display, -1, 1
    when ?n then result = move_to dungeon, display, 1, 1
    when ?\C-p then display.message.list_all
    end
    return result
  end

  public
  def show_status status_bar
    status_bar.clear
    status_bar << "#{nickname} HP:#{@tmp_hp}/#{@eff_hp}/#{@max_hp}"
    status_bar.refresh
  end

end
