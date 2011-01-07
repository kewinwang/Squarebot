class Example < Squarebot::Plugin
  
  register self, "are you an example?", "yes, I am"

  def initialize
    @messages = 0
  end

  def respond(message, user, options)
        return "yes, and I've seen #{@messages} messages so far" if message.downcase == "are you an example?"
        return nil
  end
  
  def react(message, user, options)
    @messages ||= 0
    @messages += 1
    return nil
  end
  
end

