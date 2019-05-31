class Tape < Struct.new(:left, :middle, :right, :blank)
  def inspect
    "#<Tape #{left.join}{#{middle}}#{right.join}>"
  end
  def write(character)
    Tape.new(left, character, right, blank)
  end
  def move_head_left()
    Tape.new(left[0..-2], left.last || blank, [middle] + right, blank)
  end
  def move_head_right()
    Tape.new(left + [middle], right.first || blank, right.drop(1), blank)
  end
end

class TMConfiguration < Struct.new(:state, :tape)
end

class TMRule < Struct.new(:state, :character, :next_state,
                          :write_character, :direction)
  def apply_to?(configuration)
    state == configuration.state && character == configuration.tape.middle
  end
  def follow(configuration)
    TMConfiguration.new(next_state, next_tape(configuration))
  end
  def next_tape(configuration)
    tape = configuration.tape.write(write_character)
    case direction
    when :left
      tape.move_head_left
    when :right
      tape.move_head_right
    end
  end
end
