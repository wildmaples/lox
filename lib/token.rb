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

  def line
    # line number starts from 1
    @line + 1
  end
end
