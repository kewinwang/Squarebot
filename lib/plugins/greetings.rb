class Greetings < Squarebot::Plugin
  
  register self, "hello/morning/hi/good day/good afternoon/good morning", "morning/afternoon <name>"

  def initialize
    @messages = 0

  end

  def respond(message, user, options)
    return nil
  end
  
  def react(message, user, options)
    @greetings = ['hello', 'good morning', 'morning', 'good afternoon', 'gday', 'howdy', "g'day", 'hi', 'afternoon', 'bonjour', 'ayup']
    @responses = ['howdy', "g'day", 'bonjour', 'ayup', 'nice of you to show up']
    
    if @greetings.include?(message.downcase)
      puts "user: #{user}"
      u = Campfire.user(user)
      return "#{@responses.sample} #{u["name"].split()[0]}"
    end
      
    return nil
  end
  
end

