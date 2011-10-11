#has access to method speak(message)
require 'rubygems'
require 'net/http'
require 'net/https'
require 'json'
require 'pp'
require 'active_support/core_ext'


class WhereShould < Squarebot::Plugin


  def initialize
    @foursquare = {
      # time of day = now, radius = .5mi
      :rex => "https://api.foursquare.com/v2/venues/explore?ll=(ll)&radius=500&oauth_token=(token)&vod=20111005(query)"
    }

    @initialized = false
  end
  
  #passing 'foursquare' at the end tells squarebot that it needs options under the 'foursquare' heading in the yml file.
  register self, "@squarebot where should we get <keyword>", "you should get <keyword> at any of these places: (places)", 'foursquare'

  def initialize_foursquare(options)
    @foursquare[:rex] = @foursquare[:rex].gsub("(token)", options['token'])
    @foursquare[:ll] = options['ll']
    @foursquare[:ll2] = options['ll2']
    @initialized = true
    @http = Net::HTTP.new(URI.parse(@foursquare[:rex]).host, URI.parse(@foursquare[:rex]).port)
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  def ssl_get_json(uri)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = @http.request(request)
    JSON::parse(response.body)
  end

  def get_rex(p, ll)
    query = p.strip.chomp("?").downcase
    if (query.size > 0)
      query = "&query=#{query}"
    end
    puts URI.escape(@foursquare[:rex].gsub("(query)", query).gsub("(ll)", ll))
    data = ssl_get_json(URI.parse(URI.escape(@foursquare[:rex].gsub("(query)", query).gsub("(ll)", ll))))
    pp data
    data['response']['groups'].each do |group|
      next unless group['type'] == 'recommended'
      return group['items']
    end
    return nil
  end

  def respond(message, user, options)
    message = message.downcase
    initialize_foursquare(options) if !@initialized
    response = []
    query = ""
    if results = message.match(/\Awhere\s+should\s+(i|we)\s+(go|get)\s+(.*)/)
      puts results.inspect
      next unless results.size > 3
      insf = false
      puts results[3]
      query = (results[3] || "").strip("?")
      sf = /(in|near|around|at)\s+(sf|san francisco)/
      insf = query.match(sf)
      query = query.gsub(sf, "")
      ll = insf ? @foursquare[:ll2] : @foursquare[:ll]
      rex = get_rex(query, ll)
      rex.take(2).each do |rec_detail|
        name = rec_detail['venue']['name']
        distance = rec_detail['venue']['location']['distance']
        address = rec_detail['venue']['location']['address']
        first_reason = rec_detail['reasons']['items'][0..1].map{|i| i['message']}.first
        message = "#{name}: #{address}, #{distance} meters away. #{first_reason}."
        if (rec_detail['tips'] && rec_detail['tips'].size > 0)
          tip = rec_detail['tips'][0]
          tip_text = tip['text']
          tip_user = tip['user']
          message += " '#{tip_text}'"
        end
        message += " (http://foursquare.com/venue/#{rec_detail['venue']['id']})"
        response << message
      end
      return response.size == 0 ? "no recommendations, sorry!" : response
    else
      puts "nil" 
      return nil
    end
  end
  
  
  def react(message, user, options)
    return nil
    
  end





end

