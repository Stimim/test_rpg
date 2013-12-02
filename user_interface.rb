#!/usr/bin/env ruby

# Defines some methods that MUST be implemented by a real UI
class UserInterface
  # beep at user
  def beep
    raise NoMethodError.new("undefined method `#{__method__}' for #{self}")
  end

  # prints a symbol on the dungeon at (x, y),
  # each type of things has a unique symbol, please see symbol.rb for detail
  def print_dungeon_symbol x, y, symbol
    raise NoMethodError.new("undefined method `#{__method__}' for #{self}")
  end

  # the location of current monster
  # this will be called before each time a monster is waiting for player's cmd
  def set_current_pos x, y
    raise NoMethodError.new("undefined method `#{__method__}' for #{self}")
  end

  # prints a single line message (but you can wrap them if nessecery)
  def print_message msg
    raise NoMethodError.new("undefined method `#{__method__}' for #{self}")
  end

  # clears the message area
  def clear_message
    raise NoMethodError.new("undefined method `#{__method__}' for #{self}")
  end

  # prints bunch of messages, one per line (but you can wrap them if nessecery)
  # msgs[0] is the latest message, msgs[-1] is the oldest one
  def print_messages msgs
    raise NoMethodError.new("undefined method `#{__method__}' for #{self}")
  end

  # prints the content of the file, don't show any message if no such file AND
  # ignore_missing is true.
  def print_file filename, ignore_missing
    raise NoMethodError.new("undefined method `#{__method__}' for #{self}")
  end

  # returns a single character input from the user
  def getchar
    raise NoMethodError.new("undefined method `#{__method__}' for #{self}")
  end

  # ask `question', let user choose from `choices'
  #
  # question: a string
  # choices:  an array of choice, each is a two element array, first element is
  #           a character, second is a string
  # default:  an integer, indicates the default choice in choices.
  #           When user press something not in the choices list, return default
  #           choice. If default is negative, then there is no default choice,
  #           ignore any input that is not in the choices list.
  def choose question, choices, default
    raise NoMethodError.new("undefined method `#{__method__}' for #{self}")
  end

  # ask an yes no question, default is either 1 for yes or 0 for no,
  # returns 1 for yes, 0 for no
  def yes_no_question question, default
    raise NoMethodError.new("undefined method `#{__method__}' for #{self}")
  end

  # ask a question, returns a string
  def getline question
    raise NoMethodError.new("undefined method `#{__method__}' for #{self}")
  end
end

