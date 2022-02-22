class Token
  def initialize(type, lexeme, literal, line)
    @type = type
    @lexeme = lexeme
    @literal = literal
    @line = line
  end

  attr_accessor :type, :lexeme, :literal

  def to_s
    "#{@type} #{@lexeme} #{@literal || "null"}"
  end
end
