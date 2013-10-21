
client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = "consumer_key"
  config.consumer_secret     = "consumer_secret"
  config.access_token        = "access_token"
  config.access_token_secret = "access_token_secret"
end


redis=Redis.new

client.filter(locations: "-180,-90,180,90" ) do |t|
	if t.geo?
	# here are some fields yoy might be interested on:
	#	
	# data={tid: t.id, text: t.text, date: t.created_at,
	# 	source: t.source, uid: t.user.id, screen_name: t.user.screen_name,
	#  	name: t.user.name, followers_count: t.user.followers_count, friends_count: t.user.friends_count,
	#  	statuses_count: t.user.statuses_count, time_zone: t.user.time_zone,
	#  	latitude: t.geo.coordinates[0], longitude: t.geo.coordinates[1] }.to_json

		data={date: t.created_at, latitude: t.geo.coordinates[0].to_s,
			longitude: t.geo.coordinates[1].to_s, weight: 5, uid: t.user.id,
			screen_name: t.user.screen_name,
			text: t.text, profile_image: t.user.profile_image_url, full_name: t.user.name, uid: t.user.id, source: t.source }
			puts "#{data[:latitude]} #{data[:longitude]} #{data[:full_name]} #{data[:uid]}"
			redis.publish("namespaced:stream", data.to_json)
	end  
end

redis.close