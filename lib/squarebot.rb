$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)
require 'rubygems'
require 'campfire'
require 'yaml'
require 'yajl'
require "yajl/http_stream"
module Squarebot
  
  #PLUGINS ARE SIMPLE!
  #Check out plugins/example.rb
  
  class Plugin
    def self.register(plugin, inputs, outputs, option = nil)
      @@plugins ||= {}
      @@plugins[plugin.new] = [inputs, outputs, option]
    end
    def self.all
      return @@plugins || {}
    end
  end

  class Bot

    #On every message received the bot calls plugin.react for every plugin
    #Also, if a message is directed at squarebot it calls respond on every plugin.
    #It is up to the plugin to decide whether it should respond to the input or not

    def initialize(yml_file = './config.yml')
      @options = YAML::load_file(yml_file)
      puts @options.inspect
      @campfire = @options['campfire']
      Campfire.setup(@campfire['token'])
      Dir.glob(File.join(File.dirname(__FILE__), 'plugins/', '*.rb')).each {|file| require file; puts "loaded plugin #{file}" }
      @chat_room = Campfire.room(@campfire['room'])
    end


    def handle_message(message)
      #if message is @squarebot where is <arguments>
      to_return = []
      puts "received: #{message.inspect}"
      body = message['body']
      next if !body
      
      
      #REACTIONS
      Plugin.all.each {|plugin, io| 
        begin
          response = plugin.react(body, message['user_id'], @options[io[2]])
          next if !response
          response = response.join("\n") if response.is_a?(Array)
          to_return << response
        rescue StandardError => ex
           puts "plugin #{plugin.class} crashed on react!: #{ex.inspect}"
        end
      }
      
      if results = body.match(/\A\@[S|s]quarebot\s+(.+)/)  || results = body.match(/\A[S|s]quarebot:\s+(.+)/)
        #RESPONSES
        Plugin.all.each {|plugin, io| 
          begin
            response = plugin.respond(results[1], message['user_id'], @options[io[2]])
            next if !response
            response = response.join("\n") if response.is_a?(Array)
            to_return << response
          rescue StandardError => ex
            to_return << "plugin #{plugin.class} crashed on respond!"
            puts ex.message
            puts ex.backtrace
          end
        }
      end
      return to_return
    end

    def run
      response = @chat_room.join
      puts "joining room response: #{response}"
      url = URI.parse("http://#{@campfire['token']}:x@streaming.campfirenow.com//room/#{@campfire['room']}/live.json")
      Yajl::HttpStream.get(url) do |message|
        response = handle_message(message)
        response.each{|r| @chat_room.message(r)}
      end #yajl
    end #run

  end #class
    
end #module



  
