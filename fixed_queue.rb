#!/usr/bin/env ruby

class FixedQueue
  attr_reader :cap
  attr_reader :size

  include Enumerable

  def initialize _cap
    @cap = _cap
    @array = Array.new(_cap)
    @head = 0
    @size = 0
  end

  def full?
    @size == @cap
  end

  def empty?
    @size == 0
  end

  def push x
    if @size == @cap
      @array[@head] = x
      inc_head
    else
      @array[(@head + @size) % @cap] = x
      @size += 1
    end
  end

  def shift
    return nil if empty?

    x = @array[@head]
    @array[@head] = nil
    inc_head
    @size -= 1
    return x
  end

  def each
    @size.times do |i|
      yield @array[(@head + i) % @cap]
      i += 1
    end
  end

  def to_a
    collect { |x| x }
  end

  private
  def inc_head
    @head += 1
    if @head >= cap
      @head = 0
    end
  end

end
