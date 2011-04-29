require 'twss'
class Twss < Squarebot::Plugin
  
  register self, "I was at it all night", "That's what she said"

  def initialize
    @messages = 0
    TWSS.threshold = 5.0
    @last_hour = -1
  end

  def respond(message, user, options)
    return nil
  end
  
  def react(message, user, options)
    @users = {}
    
    u = @users[user] ||= Campfire.user(user)
    return nil if @last_hour == Time.now.hour
    return nil if message.downcase.match(/that'?s what she said/)
    return nil if u['name'].downcase == 'hudson'
    return nil if !TWSS(message.downcase)
    #now we know that twss == true
    @last_hour = Time.now.hour
    return "#{u['name']}: That's what she said."
  end
  
end

