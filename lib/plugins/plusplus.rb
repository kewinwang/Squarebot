require 'fileutils'
class PlusPlus < Squarebot::Plugin
  FILE = File.join(Squarebot.root, 'plusplus.json')
  register self, "plus plus, minus minus", "you know how it works"

  def persist
    File.open(FILE, 'w'){|file| file.puts(@data.to_json)}
  end

  def initialize
    @parser = Yajl::Parser.new
    raw = File.exists?(FILE) ? File.open(FILE).read : "{}"
    @data = @parser.parse(raw)
  end

  def respond(message, user, options)
    initialize()
    if(message.downcase == "show leaderboard" || message.downcase == "leaderboard")

      top = ["TOP"] + @data.sort_by{|k,v| v}.reverse.take(3).map{|k,v| "#{k}: #{v}"}
      top += ["BOTTOM"] + @data.sort_by{|k,v| v}.take(3).map{|k,v| "#{k}: #{v}"} if @data.size > 3
      return top
    end
    nil
  end

  def react(message, user, options)
    if (message.include?("++") || message.include?("--")) && !message.match(/:|\*|\s|;|\n/)
      initialize()
      plus = /(\+\+)+/
      minus = /(--)+/
      matches = message.match(/([^+-:\s\n]+)(#{plus}|#{minus})/)
      name = matches[1]

      direction = matches[2].match(plus) ? (matches[2].size / 2.0).floor : (matches[2].size / 2.0).floor * -1
      puts "found: #{name}, #{direction}"
      @data[name] ||= 0
      @data[name] += direction
      goodbad = direction > 0 ? "woot!" : "oh noes!"
      persist
      return "#{name} now at #{@data[name]} (#{goodbad})"
    end
  end

end
