#!/usr/bin/env ruby

# any beings in the game should extend this class.
class Being
  def self.name
    "monster"
  end

  def initialize
    @speed = 10
    @energy = 0
    @x = nil
    @y = nil
    @limit_hp = 100
    full_heal
  end

  public
  def vision_limit
    80
  end

  public
  def receive_damage minor, major
    @minor_hp -= minor
    @major_hp -= major

    # you will always faint before die
    if @minor_hp <= 0
      try_faint
    end
    if @major_hp <= 0
      try_die
    end
  end

  public
  def tick
    @energy += @speed
    while @energy > 0 and Provider.get_game.alive?
      @energy -= next_move
    end
  end

  public
  def blocks?
    return false
  end

  public
  def enter_level level, how
    level.add_monster self, how
  end

  # returns a non-negative value indicates the energy cost
  private
  def next_move
    ai_move
  end

  @@moves = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]
  private
  def ai_move
    cost = 0
    @@moves.each do |dx, dy|
      cost = try_move_to(cor_x + dx, cor_y + dy)

      break if cost > 0
    end
    return cost
  end

  public
  def cor_x
    return @x
  end

  public
  def cor_y
    return @y
  end

  public
  def move_to nx, ny
    # puts "#{self} move to #{nx}, #{ny}"
    base_cost, nx, ny = Provider.get_dungeon.move_to self, cor_x, cor_y, nx, ny
    @x = nx
    @y = ny
    return base_cost
  end

  public
  def try_move_to nx, ny
    result = Provider.get_dungeon.try_move_to self, nx, ny

    # puts "try move to #{nx} #{ny}, result = #{result}"
    return move_to(nx, ny) if result == true

    return 0 if result == false # you simply can't move to there

    if result.is_a? Being
      return 0
    end
  end

  public
  def die
    msg = "A mystery power brought #{the_name} back from hell"

    full_heal

    Provider.get_player.receive_message msg
  end

  public
  def full_heal
    @minor_hp = @limit_hp
    @major_hp = @limit_hp
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

  def next_move
    return control if controlled?
    ai_move
  end

  def controlled?
    @controlled
  end

  def set_control b
    @controlled = b
  end

  # returns 0 if nothing is done,
  # returns a positive value indicates energy cost
  #
  # cmd is an Fixnum, represents the key user pressed.
  public
  def take_action cmd
    cost = 0
    cost = (Provider.get_dungeon.take_action self, cmd) if cost == 0
    cost = (basic_action cmd) if cost == 0
    Provider.get_ui.print_message "no such command '#{cmd.chr}'" if cost == 0
    return cost
  end

  # returns 0 if nothing is done,
  # returns a positive value indicates energy cost
  public
  def control
    Provider.get_player.update_vision
    ui = Provider.get_ui
    self.show_status
    ui.set_current_pos cor_x, cor_y
    cmd = ui.getchar
    ui.clear_message
    return take_action cmd
  end

  public
  def basic_action cmd
    result = 0
    case cmd
    when ?Q
      result = -1
      Provider.get_ui.print_message "Quit? [y/N]"
      answer = Provider.get_ui.getchar
      if answer == ?Y or answer == ?y
        Provider.get_game.over
      else
        Provider.get_ui.print_message "Never mind."
      end
    when ?l then result = try_move_to cor_x + 1, cor_y + 0
    when ?h then result = try_move_to cor_x - 1, cor_y + 0
    when ?j then result = try_move_to cor_x + 0, cor_y + 1
    when ?k then result = try_move_to cor_x + 0, cor_y - 1
    when ?y then result = try_move_to cor_x - 1, cor_y - 1
    when ?u then result = try_move_to cor_x + 1, cor_y - 1
    when ?b then result = try_move_to cor_x - 1, cor_y + 1
    when ?n then result = try_move_to cor_x + 1, cor_y + 1
    when ?\C-p then Provider.get_player.show_messages
    end
    return result
  end

  public
  def show_status
  end

end
