class RuntimeError
  def initialize(token, message)
    @token = token
    @message = message
  end

  attr_accessor :token, :message

  def get_message
    message
  end
end
