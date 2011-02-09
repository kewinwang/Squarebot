class Greetings < Squarebot::Plugin
  
  register self, "hello/morning/hi/good day/good afternoon/good morning", "morning/afternoon <name>"

  def initialize
  end

  def respond(message, user, options)
    return nil
  end
  
  def react(message, user, options)
    @greetings = ['hello', 'good morning', 'morning', 'good afternoon', 'gday', 'howdy', "g'day", 'hi', 'afternoon', 'bonjour', 'ayup']
    @responses = ['howdy', "g'day", 'bonjour', 'ayup', 'nice of you to show up']
    @users ||= {}
    if @greetings.include?(message.downcase)
      puts "user: #{user}"
      #this means I cache user info so I don't have to make multiple calls for the same user. SMRT smart
      u = @users[user] ||= Campfire.user(user)
      return "#{@responses.sample} #{u["name"].split()[0]}"
    end
      
    return nil
  end
  
end

