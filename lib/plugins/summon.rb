require 'net/http'
require 'net/https'
require 'json'
require 'active_support/core_ext'

class Summon < Squarebot::Plugin
  
  register self, "@squarebot summon name[,othernames] : [message]", "matthew emailed & sms'd", 'overshare'

  def initialize
    
  end

  def ping(person, message)
    url = URI.parse("https://overshare.foursquare.com/api/summon")
    post = Net::HTTP::Post.new(url.request_uri)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    post.set_form_data({"to" => person, "message" => message, "secret" => @secret})

    http.request(post).body
  end


  def respond(message, user, options)
    
    unless message.start_with?("summon")
      return nil
    end
    
    @secret = options["secret"]
    if message.downcase == "help summon" || message.downcase == "summon help" || message.downcase == "summon --help"
      return "=> @squarebot summon name,name2,namex : hey guys, stuff is broken, need your help"
    end
    @users ||= {}
    u = (@users[user] ||= Campfire.user(user))["name"]

    names, msg = message.split(/\s*:\s*/)
    names = names.gsub(/\s*summon\s*/, "").split(/\s*,\s*/)
    msg = "#{u}: #{msg}"
    results = []
    names.each do |name|
      puts "pinging #{name} with #{msg}"
      result = ping(name, msg)
      results << "@#{u}, results for #{name}: #{result}"
    end

    results
  end
  
end

