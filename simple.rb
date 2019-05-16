class Number < Struct.new(:value)
  def to_s
      value.to_s
  end
  def inspect
      "«#{self}»"
  end
  def reducible?
    false
  end
end

class Add < Struct.new(:left, :right)
  def to_s
    "#{left} + #{right}"
  end
  def inspect
      "«#{self}»"
  end
  def reducible?
    true
  end
  def reduce(environment)
    if left.reducible?
      [Add.new(left.reduce(environment), right), environment]
    elsif right.reducible?
      [Add.new(left, right.reduce(environment)), environment]
    else
      [Number.new(left.value + right.value), environment]
    end
  end
end

class Multiply < Struct.new(:left, :right)

  def to_s
    "#{left} * #{right}"
  end

  def inspect
      "«#{self}»"
  end

  def reducible?
    true
  end

  def reduce(environment)
    if left.reducible?
      [Multiply.new(left.reduce(environment), right), environment]
    elsif right.reducible?
      [Multiply.new(left, right.reduce(environment)), environment]
    else
      [Number.new(left.value * right.value), environment]
    end
  end

end

class Boolean < Struct.new(:value)
  def to_s
    value.to_s
  end
  def inspect
    "«#{self}»"
  end
  def reducible?
     false
  end
end

class LessThan < Struct.new(:left, :right)
  def to_s
    "#{left} < #{right}"
  end
  def inspect
    "«#{self}»"
  end
  def reducible?
    true
  end

  def reduce(environment)
    if left.reducible?
      [LessThan.new(left.reduce(environment), right), environment]
    elsif right.reducible?
      [LessThan.new(left, right.reduce(environment)), environment]
    else
      [Boolean.new(left.value < right.value), environment]
    end
  end
end

class DoNothing
  def to_s
    "do-nothing"
  end
  def inspect
    "«#{self}»"
  end
  def ==(other_statement)
    other_statement.instance_of?(DoNothing)
  end
  def reducible?
    false
  end
end

class Variable < Struct.new(:name)
  def to_s
    name.to_s
  end

  def inspect
    "«#{self}»"
  end
  def reducible?
    true
  end

  def reduce(environment)
     environment[name]
  end
end

class Assign < Struct.new(:name, :expression)
  def to_s
    "#{name} = #{expression}"
  end
  def inspect
    "«#{self}»"
  end
  def reducible?
    true
  end

  def reduce(environment)
    if expression.reducible?
      exp, env = expression.reduce(environment)
      [Assign.new(name, exp), env]
    else
      [DoNothing.new, environment.merge({ name => expression })]
    end
  end
end

class If < Struct.new(:condition, :consequence, :alternative)
  def to_s
    "if (#{condition}) {#{consequence} else #{alternative}}"
  end

  def inspect
    "«#{self}»"
  end

  def reducible?
    true
  end

  def reduce(environment)
    if condition.reducible?
      cond, env = condition.reduce(environment)
      [If.new(cond, consequence, alternative), env]
    else
      case condition
      when Boolean.new(true)
        [consequence, environment]
      when Boolean.new(false)
        [alternative, environment]
      end
    end
  end

end

class Sequence < Struct.new(:first, :second)
  def to_s
    "#{first}, #{second}"
  end
  def inspect
    "«#{self}»"
  end
  def reducible?
    true
  end
  def reduce(environment)
    case first
    when DoNothing.new
      [second, environment]
    else
      f, env = first.reduce(environment)
      [Sequence.new(f, second), env]
    end
  end
end

class Machine < Struct.new(:expression, :environment)
  def step
    self.expression, self.environment = expression.reduce(environment)
  end

  def run
    while expression.reducible?
      puts "step: #{expression}, #{environment}"
      step
    end
    puts "result: #{expression}, #{environment}"
  end
end

Machine.new(
  Sequence.new(
    Assign.new(:x, Add.new(Number.new(1), Number.new(1))),
    Assign.new(:y, Add.new(Variable.new(:x), Number.new(3)))),
{}).run
