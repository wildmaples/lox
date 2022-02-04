require_relative 'token'
require_relative 'token_type'

class Scanner
  def initialize(io)
    @source = File.open(io).read
    @tokens = []

    @start = 0
    @current = 0
    @line = 0
  end

  SYMBOL_TO_TOKEN_MAP = {
    "(" => :LEFT_PAREN,
    ")" => :RIGHT_PAREN,
    "{" => :LEFT_BRACE,
    "}" => :RIGHT_BRACE,
    "," => :COMMA,
    "." => :DOT,
    "-" => :MINUS,
    "+" => :PLUS,
    ";" => :SEMICOLON,
    "*" => :STAR
  }

  DOUBLE_CHAR_SYMBOLS_TO_TOKEN_MAP = {
    "!" => [:BANG_EQUAL, :BANG],
    "=" => [:EQUAL_EQUAL, :EQUAL],
    "<" => [:LESS_EQUAL, :LESS],
    ">" => [:GREATER_EQUAL, :GREATER]
  }

  WHITESPACE = [" ", "\r", "\t", "\n"]
  DIGIT = %w[0 1 2 3 4 5 6 7 8 9]
  ALPHABET = ("a".."z").to_a + ("A".."Z").to_a + ["_"]

  def scan
    while !end_of_source
      @start = @current
      scan_token
    end

    @tokens << Token.new(:EOF, "", nil, @line)
  end

  private

  def scan_token
    char = advance

    case char

    when *WHITESPACE
      @line += 1 if char == "\n"

    when *SYMBOL_TO_TOKEN_MAP.keys
      add_token(SYMBOL_TO_TOKEN_MAP[char], @source[@start...@current])

    when *DOUBLE_CHAR_SYMBOLS_TO_TOKEN_MAP.keys
      double_char, single_char = DOUBLE_CHAR_SYMBOLS_TO_TOKEN_MAP[char]
      add_token(match_char("=") ? double_char : single_char, @source[@start...@current])

    when "/"
      if match_char("/")
        @current = @source.index("\n", @current) || @source.length
      else
        add_token(:SLASH, @source[@start...@current])
      end

    when '"'
      string

    when *DIGIT
      number

    when *ALPHABET
      identifier

    else
      Lox.error(@line, "Unexpected character!")
    end
  end

  def string
    closing_index = @source.index('"', @current)
    return Lox.error(@line, "Unterminated string!") if closing_index.nil?

    string_text = @source[@start..closing_index]
    add_token(:STRING, string_text, @source[@start + 1...closing_index])
    advance_from(index: closing_index)
  end

  def number
    match = @source.match(%r{[0-9]+.[0-9]+}, @start)
    if match
      number = @source[@start...match.end(0)]
      add_token(:NUMBER, number, number.to_f)
      advance_from(index: match.end(0) - 1)
    end
  end

  def identifier
    match = @source.match(%r{[\w_]+}, @start)
    if match
      text = @source[@start...match.end(0)]
      type = TokenType::KEYWORD.include?(text.to_sym.upcase) ? text.to_sym.upcase : :IDENTIFIER
      add_token(type, text)
      advance_from(index: match.end(0) - 1)
    end
  end

  def advance_from(index:)
    @current = index
    advance
  end

  def advance
    char = @source[@current]
    @current += 1
    char
  end

  def add_token(type, text, literal = nil)
    @tokens << Token.new(type, text, literal, @line)
  end

  def end_of_source
    @current >= @source.length
  end

  def match_char(expected)
    return if end_of_source
    return false if @source[@current] != expected

    @current += 1
    true
  end
end
