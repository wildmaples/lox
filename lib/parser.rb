require_relative 'ast/expression'
require_relative 'ast/statement'

class Parser
  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  attr_accessor :tokens, :current

  def parse
    statements = []
    while !is_at_end?
      statements << declaration
    end

    statements
  end

  def expression
    assignment
  end

  def declaration
    begin
      return var_declaration if match(:VAR)
      return statement
    rescue ParseError => e
      synchronize
      nil
    end
  end

  def statement
    return print_statement if match(:PRINT)
    return AST::Statement::Block.new(block) if match(:LEFT_BRACE)
    expression_statement
  end

  def print_statement
    value = expression
    consume(:SEMICOLON, "Expect ';' after value.")
    AST::Statement::Print.new(value)
  end

  def var_declaration
    name = consume(:IDENTIFIER, "Expect variable name.")
    initializer = nil
    if match(:EQUAL)
      initializer = expression
    end

    consume(:SEMICOLON, "Expect ';' after variable declaration.")
    AST::Statement::Var.new(name, initializer)
  end

  def expression_statement
    expr = expression
    consume(:SEMICOLON, "Expect ';' after value.")
    AST::Statement::Expression.new(expr)
  end

  def block
    statements = []
    while !check(:RIGHT_BRACE) && !is_at_end?
      statements << declaration
    end

    consume(:RIGHT_BRACE, "Expect '}' after block.")
    statements
  end

  def assignment
    expr = equality

    if match(:EQUAL)
      equals = previous
      value = assignment

      if expr.is_a?(AST::Statement::Variable)
        name = expr.name
        return AST::Expression::Assign.new(name, value)
      end

      error(equals, "Invalid assignment target.")
    end

    expr
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

    if match(:IDENTIFIER)
      return AST::Statement::Variable.new(previous)
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

  def consume(type, message)
    return advance if check(type)
    raise error(peek, message)
  end

  def check(type)
    return false if is_at_end?
    peek.type == type
  end

  def advance
    if !is_at_end?
      token = tokens[@current]
      @current += 1
      return token
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

  def error(token, message)
    Lox.error(token, message)
    ParseError.new
  end

  def synchronize
    advance
    while !is_at_end?
      return if previous.type == :SEMICOLON

      case peek.type
      when :CLASS, :FUN, :VAR, :FOR, :IF, :WHILE, :PRINT, :RETURN
        return
      end

      advance
    end
  end

  class ParseError < Exception; end
end
