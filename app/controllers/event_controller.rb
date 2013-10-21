class EventController < WebsocketRails::BaseController
	  
	def initialize_session
	    connection_store[:counter] = 0
	    connection_store[:pre_counter] = 0
	    connection_store[:thread]=[nil]
	end

	def tweets
	    logger.info "Stream opened"
	    connection_store[:swlat]=message[:swlat].to_f
	    connection_store[:swlng]=message[:swlng].to_f
	    connection_store[:nelat]=message[:nelat].to_f
	    connection_store[:nelng]=message[:nelng].to_f
	    logger.info "#{connection_store[:swlat]} #{ connection_store[:swlng]} #{ connection_store[:nelat]} #{ connection_store[:nelng]}"
	    
		unless connection_store[:thread][0]
			logger.info "creating thread"
		    connection_store[:thread][0] = Thread.new do
			    $redis.subscribe('namespaced:stream') do |on|
			    	on.message do |event,data|
			    		d=ActiveSupport::JSON.decode(data)
			    		lat=d["latitude"].to_f
			    		lng=d["longitude"].to_f			    		
			    		if (connection_store[:swlat]..connection_store[:nelat]).include?(lat) and (connection_store[:swlng]..connection_store[:nelng]).include?(lng)
			    			data={lat: d["latitude"], lng: d["longitude"], weight: 10, created_at: d["date"],full_name: d["full_name"], uid: d["uid"],profile_image: "#{d["profile_image"]["scheme"]}://#{d["profile_image"]["host"]}#{d["profile_image"]["path"]}",
			    				screen_name: d["screen_name"]}
			    			send_message(:tweets, data)
			    		end
			    	end
			    end
			end
		end
	end
end