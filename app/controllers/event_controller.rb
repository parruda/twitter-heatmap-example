class EventController < WebsocketRails::BaseController
	  
	def initialize_session
	    
	end

	def tweets
	    logger.info "Stream opened"
	    connection_store[:swlat]=message[:swlat].to_f
	    connection_store[:swlng]=message[:swlng].to_f
	    connection_store[:nelat]=message[:nelat].to_f
	    connection_store[:nelng]=message[:nelng].to_f
	    logger.info "#{connection_store[:swlat]} #{ connection_store[:swlng]} #{ connection_store[:nelat]} #{ connection_store[:nelng]}"
	    
	end


	def spawn_thread
		connection_store[:thread]=[]
	    connection_store[:swlat]=nil
	    connection_store[:swlng]=nil
	    connection_store[:nelat]=nil
	    connection_store[:nelng]=nil
	    connection_store[:break]=false
	    connection_store[:redis]=Redis.new
	    connection_store[:thread][0] = Thread.new do
	    	logger.info "creating thread #{connection_store[:thread][0]}, connection: #{connection_store[:connection]}"
		    connection_store[:redis].subscribe('namespaced:stream') do |on|
		    	break if connection_store[:break]
		    	on.message do |event,data|
		    		break if connection_store[:break]
		    		if connection_store[:swlat]
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
		    Thread.current.kill
		end

	end


	def kill_thread
		logger.info "client disconnected, killing thread"
		connection_store[:break]=true
		#logger.info connection_store[:thread][0].status
		#logger.info "trying to quit redis connection"
		connection_store[:redis].quit
		#logger.info "done. trying to kill thread"
		connection_store[:thread][0].kill
		#logger.info connection_store[:thread][0].status
		#logger.info "killed."
	end
end