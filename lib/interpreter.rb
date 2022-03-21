require_relative "runtime_error"
require_relative 'lox'

class Interpreter
  def interpret(statements)
    begin
      statements.each do |statement|
        execute(statement)
      end
    rescue RuntimeError => e
      Lox.runtime_error(e)
    end
  end

  def stringify(text)
    if text.class == Float
      text.to_i
    else
      text
    end
  end

  def evaluate(expr)
    expr.accept(self)
  end

  def execute(stmt)
    stmt.accept(self)
  end

  def visit_expression_stmt(stmt)
    evaluate(stmt.expression)
  end

  def visit_print_stmt(stmt)
    value = evaluate(stmt.expression)
    puts stringify(value)
  end

  def visit_literal_expr(expr)
    expr.value
  end

  def visit_unary_expr(expr)
    right = evaluate(expr.right)

    case expr.operator.type
    when :BANG
      !right # we don't need is_truthy
    when :MINUS
      check_number_operand(expr.operator, right)
      -right
    end
  end

  def visit_grouping_expr(expr)
    evaluate(expr.expression)
  end

  def visit_binary_expr(expr)
    left = evaluate(expr.left)
    right = evaluate(expr.right)

    case expr.operator.type
    when :GREATER
      check_number_operands(expr.operator, left, right)
      left > right

    when :GREATER_EQUAL
      check_number_operands(expr.operator, left, right)
      left >= right

    when :LESS
      check_number_operands(expr.operator, left, right)
      left < right

    when :LESS_EQUAL
      check_number_operands(expr.operator, left, right)
      left <= right

    when :MINUS
      check_number_operands(expr.operator, left, right)
      left - right

    when :PLUS
      check_same_type_operands(left, right)
      left + right # Ruby takes care of Integer and String addition

    when :SLASH
      check_number_operands(expr.operator, left, right)
      left / right

    when :STAR
      check_number_operands(expr.operator, left, right)
      left * right

    when :BANG_EQUAL
      check_same_type_operands(left, right)
      left != right

    when :EQUAL_EQUAL
      check_same_type_operands(left, right)
      left == right
    end
  end

  private

  def check_number_operand(operator, operand)
    raise RuntimeError.new(operator, "Operand must be a number.") unless operand.is_a?(Numeric)
  end

  def check_number_operands(operator, left, right)
    raise RuntimeError.new(operator, "Operand must be a number.") unless left.is_a?(Numeric) && right.is_a?(Numeric)
  end

  def check_same_type_operands(left, right)
    is_string = left.is_a?(String) && right.is_a?(String)
    is_integer = left.is_a?(Numeric) && right.is_a?(Numeric)
    raise RuntimeError.new(operator, "Operands must be a number or string for + operation.") unless is_string or is_integer
  end
end
