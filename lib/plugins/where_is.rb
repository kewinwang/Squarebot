#has access to method speak(message)
require 'rubygems'
require 'net/http'
require 'net/https'
require 'json'
require 'active_support/core_ext'


class WhereIs < Squarebot::Plugin


  def initialize
    @foursquare = {
      :friends => "https://api.foursquare.com/v2/users/self/friends?oauth_token=(token)",
      :user => "https://api.foursquare.com/v2/users/%userid%?oauth_token=(token)"
    }

    @initialized = false
  end
  
  register self, "@squarebot where is <name | initials>", "<name> was last seen at foursquare HQ (link)", 'foursquare'

#NOT WORKING YET
  def initialize_foursquare(options)
    @foursquare[:friends] = URI.parse(@foursquare[:friends].gsub("(token)", options['token']))
    @foursquare[:user].gsub!("(token)", options['token'])
    @initialized = true
    @http = Net::HTTP.new(@foursquare[:friends].host, @foursquare[:friends].port)
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  def ssl_get_json(uri)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = @http.request(request)
    JSON::parse(response.body)
  end



  def get_friends
    data = ssl_get_json(@foursquare[:friends])
    return data['response']['friends']['items']
  end

  def find_people(p)
    p = p.strip.chomp("?").downcase
    friends = get_friends() #returns an array of friends
    split = p.split /\s+/
    if p.size == 2
      split = p.split(//)
      return friends.select{|f|
        fst = f['firstName'] ? f['firstName'].split('')[0].downcase : ""
        scd = f['lastName'] ? f['lastName'].split('')[0].downcase : ""
        split[0] == fst && split[1] == scd
      }
      # initials
    else
      return friends.select{|f| f['firstName'] && f['firstName'].downcase == p}
    end
  end

  def get_locations(people)
  #  puts people.inspect
    results = []
    puts "getting locations for #{people.size} people"
    people.each do |person|
      begin
        data = ssl_get_json(URI.parse(@foursquare[:user].gsub('%userid%', person['id'])))
    #    puts data.inspect
        next if !data['response']['user']['checkins'] || data['response']['user']['checkins']['items'].size == 0
        
        all_checkins = data['response']['user']['checkins']['items']
        checkin = all_checkins[0]

        message = "#{person['firstName']} #{person['lastName']} was last seen"
        if checkin['type'] == 'shout'
          message += " shouting '#{all_checkins[0]['shout']}', but not at any venue"
        else
          message += " at #{checkin['venue']['name']} in #{checkin['venue']['location']['city']}"
        end
        hours = ((Time.now - Time.at(checkin['createdAt'])) / 1.hour).to_i + 1
        message = "#{message} less than #{hours} #{hours == 1 ? "hour" : "hours"} ago"
        message = "#{message} (http://foursquare.com/user/#{checkin['userid']}/checkin/#{checkin['id']})" if checkin['type'] != 'shout'

        results << message
      rescue StandardError => ex
        puts ex.message
        puts ex.backtrace
      end
    end
    return results
  end


  def respond(message, user, options)
    initialize_foursquare(options) if !@initialized
    response = []
    if results = message.match(/\Awhere\s+is(.+)/)
      next unless results.size > 1
      matching_friends = find_people(results[1])
      response = get_locations(matching_friends)
      return response.size == 0 ? "I didn't find anyone matching your search, sorry!" : response
    else
      return nil
    end
  end
  
  
  def react(message, user, options)
    return nil
    
  end





end

