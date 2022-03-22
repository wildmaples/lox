require_relative 'scanner'
require_relative 'parser'
require_relative 'ast/expression'
require_relative 'interpreter'

class Lox
  @@had_error = false
  @@had_runtime_error = false

  def prompt
    raise NotImplementedError
  end

  def run_file(input)
    run(File.open(file))
    exit(80) if @@had_runtime_error
  end

  def run(io)
    tokens = Scanner.new(io).scan
    statements = Parser.new(tokens).parse
    exit(65) if @@had_error
    interpreter = Interpreter.new.interpret(statements)
  end

  def self.error(token, msg)
    if token.type == :EOF
      report(token.line, " at end", msg)
    else
      report(token.line, " at '#{token.lexeme}'", msg)
    end
  end

  def self.report(line, where, msg)
    puts "[#{line}] Error#{where}: #{msg}"
    @@had_error = true
  end

  def self.runtime_error(error)
    puts "#{error.get_message} [line #{error.token.line}]"
    @@had_runtime_error = true
  end
end
