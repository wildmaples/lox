require_relative 'runtime_error'

class Environment
  def initialize(enclosing = nil)
    @values = {}
    @enclosing = enclosing
  end

  attr_accessor :values, :enclosing

  def define(name, value)
    values[name] = value
  end

  def get(name)
    return values[name.lexeme] if values.key?(name.lexeme)
    return enclosing.get(name) if enclosing != nil
    raise RuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
  end

  def assign(name, value)
    if values.key?(name.lexeme)
      values[name.lexeme] = value
    else
      raise RuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
    end
  end
end
