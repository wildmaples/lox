require_relative 'expression'

class Parser
  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  attr_accessor :tokens, :current

  def parse
    expression
  end

  def expression
    equality
  end

  def equality
    expr = comparison

    while match(:BANG_EQUAL, :EQUAL_EQUAL)
      op = previous
      right = comparison
      expr = AST::Expression::Binary.new(expr, op, right)
    end

    expr
  end

  def comparison
    expr = term

    while match(:GREATER, :GREATER_EQUAL, :LESS, :LESS_EQUAL)
      op = previous
      right = term
      expr = AST::Expression::Binary.new(expr, op, right)
    end

    expr
  end

  def term
    expr = factor

    while match(:MINUS, :PLUS)
      op = previous
      right = factor
      expr = AST::Expression::Binary.new(expr, op, right)
    end

    expr
  end

  def factor
    expr = unary

    while match(:SLASH, :STAR)
      op = previous
      right = unary
      expr = AST::Expression::Binary.new(expr, op, right)
    end

    expr
  end

  def unary
    if match(:BANG, :MINUS)
      op = previous
      right = unary
      return AST::Expression::Unary.new(op, right)
    end

    primary
  end

  def primary
    return AST::Expression::Literal.new(:false) if match(:FALSE)
    return AST::Expression::Literal.new(:true) if match(:TRUE)
    return AST::Expression::Literal.new(:null) if match(:NULL)

    if match(:NUMBER, :STRING)
      return AST::Expression::Literal.new(previous.literal)
    end

    if match(:LEFT_PAREN)
      expr = expression
      advance if check(:RIGHT_PAREN)
      return AST::Expression::Grouping.new(expr)
    end
  end

  def match(*types)
    if types.include?(peek.type) && !is_at_end?
      advance
      true
    else
      false
    end
  end

  def check(type)
    return false if is_at_end?
    peek.type == type
  end

  def advance
    if !is_at_end?
      return @current += 1
    end
    previous
  end

  def is_at_end?
    peek.type == :EOF
  end

  def peek
    tokens[current]
  end

  def previous
    tokens[current - 1]
  end
end
