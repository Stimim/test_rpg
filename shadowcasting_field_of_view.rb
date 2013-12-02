#!/usr/bin/env ruby

module ShadowcastingFieldOfView
  # Multipliers for transforming coordinates into other octants
  MULT = [
    [1,  0,  0, -1, -1,  0,  0,  1],
    [0,  1, -1,  0,  0, -1,  1,  0],
    [0,  1,  1,  0,  0, -1, -1,  0],
    [1,  0,  0,  1, -1,  0,  0, -1],
  ]

  # Determines which co-ordinates on a 2D grid are visible
  # from a particular co-ordinate.
  # start_x, start_y: center of view
  # radius: how far field of view extends
  def self.compute_field_of_view(start_x, start_y, radius=100)
    Provider.get_player.gain_vision_at start_x, start_y
    8.times do |oct|
      self.compute_oct start_x, start_y, radius, oct
    end
  end

  # compute max v such that 0 <= a*v + b < limit
  # a is +1 or -1
  private
  def self.max_v a, b, limit
    if a == -1
      b
    elsif a == 1
      limit - b - 1
    end
  end

  private
  def self.compute_max_dx xx, yx, cx, cy, radius
    if xx != 0
      # mx = cx + xx * dx
      max_dx = max_v xx, cx, Dungeon::NCOL
    else
      # my = cy + yx * dx
      max_dx = max_v yx, cy, Dungeon::NROW
    end
    return [radius, max_dx].min
  end

  private
  def self.compute_max_dy xy, yy, cx, cy, radius
    if xy != 0
      # mx = cx + xy * dy
      max_dy = max_v xy, cx, Dungeon::NCOL
    else
      # my = cy + yy * dy
      max_dy = max_v yy, cy, Dungeon::NROW
    end
    return [radius, max_dy].min
  end

  private
  def self.compute_oct cx, cy, radius, oct
    xx = MULT[0][oct]
    xy = MULT[1][oct]
    yx = MULT[2][oct]
    yy = MULT[3][oct]

    max_dx = compute_max_dx xx, yx, cx, cy, radius
    # print "#{max_dx} "

    @@next_dy = []
    (1..max_dx).each do |dx|
      max_dy = compute_max_dy xy, yy, cx, cy, radius
      max_dy = [max_dy, dx].min
      while max_dy * max_dy + dx * dx > radius * radius
        max_dy -= 1
      end

      @@next_dy[dx] = max_dy

      # print "(#{dx}, #{@@next_dy[dx]})"
    end

    cast_light cx, cy, 1, 1.0, 0.0, max_dx, xx, xy, yx, yy
  end

  private
  def self.cast_light cx, cy, row, m_start, m_end, radius, xx, xy, yx, yy
    return if m_start < m_end

    (row..radius).each do |dx|
      blocked = false

      while @@next_dy[dx] >= 0
        dy = @@next_dy[dx]
        @@next_dy[dx] -= 1

        mx, my = cx + dx * xx + dy * xy, cy + dx * yx + dy * yy
        l_slope, r_slope = (dy+0.5)/(dx-0.5), (dy-0.5)/(dx+0.5)
        next if r_slope > m_start

        if l_slope < m_end
          @@next_dy[dx] += 1
          break
        end

        Provider.get_player.gain_vision_at mx, my

        if blocked
          if Provider.get_dungeon.blocked? mx, my
            new_start = r_slope
            next
          else
            blocked = false
            m_start = new_start
          end
        else
          if (Provider.get_dungeon.blocked? mx, my) and dx < radius
            blocked = true
            cast_light cx, cy, dx + 1, m_start, l_slope, radius, xx, xy, yx, yy
            new_start = r_slope
          end
        end
      end # while @@next_dy
      break if blocked
    end
  end

  private
  # Recursive light-casting function
  #def self.cast_light(cx, cy, row, light_start, light_end,
                      #radius, xx, xy, yx, yy, id)
    #return if light_start < light_end
    #radius_sq = radius * radius
    #(row..radius).each do |j| # .. is inclusive
      #dx, dy = -j - 1, -j
      #blocked = false

      #while dx <= 0
        #dx += 1
        ## Translate the dx, dy co-ordinates into map co-ordinates
        #mx, my = cx + dx * xx + dy * xy, cy + dx * yx + dy * yy

        #if not Provider.get_dungeon.in_range? mx, my
          #next
        #end
        ## l_slope and r_slope store the slopes of the left and right
        ## extremities of the square we're considering:
        #l_slope, r_slope = (dx-0.5)/(dy+0.5), (dx+0.5)/(dy-0.5)
        #if light_start < r_slope
          #next
        #elsif light_end > l_slope
          #break
        #else
          ## Our light beam is touching this square; light it
          #if (dx*dx + dy*dy) < radius_sq
            #Provider.get_player.gain_vision_at(mx, my)
          #end
          #if blocked
            ## We've scanning a row of blocked squares
            #if Provider.get_dungeon.blocked?(mx, my)
              #new_start = r_slope
              #next
            #else
              #blocked = false
              #light_start = new_start
            #end
          #else
            #if Provider.get_dungeon.blocked?(mx, my) and j < radius
              ## This is a blocking square, start a child scan
              #blocked = true
              #cast_light(cx, cy, j+1, light_start, l_slope,
                         #radius, xx, xy, yx, yy, id+1)
              #new_start = r_slope
            #end
          #end
        #end
      #end # while dx <= 0
      #break if blocked
    #end # (row..radius+1).each
  #end
end
