require_relative 'scanner'
require_relative 'parser'
require_relative 'expression'

class Lox
  def prompt
    raise NotImplementedError
  end

  def run_file(input)
    run(File.open(file))
    return if @had_error
  end

  def run(io)
    tokens = Scanner.new(io).scan
    expression = Parser.new(tokens).parse
    puts expression.pp
  end

  def self.error(line, msg)
    report(line, "", msg)
  end

  def self.report(line, where, msg)
    puts "[line #{line}] Error #{where}: #{msg}"
    @had_error = true
  end
end
