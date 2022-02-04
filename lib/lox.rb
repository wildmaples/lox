require_relative 'scanner'

class Lox
  def prompt
    raise NotImplementedError
  end

  def run_file(input)
    run(File.open(file))
    return if @had_error
  end

  def run(io)
    scanner = Scanner.new(io)
    puts scanner.scan
  end

  def self.error(line, msg)
    report(line, "", msg)
  end

  def self.report(line, where, msg)
    puts "[line #{line}] Error #{where}: #{msg}"
    @had_error = true
  end
end
