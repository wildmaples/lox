require_relative 'scanner'
require_relative 'parser'
require_relative 'ast/expression'
require_relative 'interpreter'

class Lox
  def prompt
    raise NotImplementedError
  end

  def run_file(input)
    run(File.open(file))
    return SystemExit.new(65) if @had_error
    return SystemExit.new(80) if @had_runtime_error
  end

  def run(io)
    tokens = Scanner.new(io).scan
    statements = Parser.new(tokens).parse
    interpreter = Interpreter.new.interpret(statements)
  end

  def self.error(line, msg)
    report(line, "", msg)
  end

  def self.report(line, where, msg)
    puts "[line #{line}] Error #{where}: #{msg}"
    @had_error = true
  end

  def self.runtime_error(error)
    puts "#{error.get_message} [line #{error.token.line}]"
    @had_runtime_error = true
  end
end
