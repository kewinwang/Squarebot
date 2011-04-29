require 'twss'
class Twss < Squarebot::Plugin
  
  register self, "I was at it all night", "That's what she said"

  def initialize
    @messages = 0
    TWSS.threshold = 2.0
  end

  def respond(message, user, options)
    return nil
  end
  
  def react(message, user, options)
    @users = {}
    u = @users[user] ||= Campfire.user(user)
    return nil if message.downcase.match(/that'?s what she said/)
    return "#{u['name']}: That's what she said." if TWSS(message)
  end
  
end

