require 'cgi'

class Cookie
	def initialize(name, value, path)
		@name = name
		@value = CGI::escape value
		@path = path
	end
	
	def delete
		setExpirationTimestamp 0
	end
	
	def expirationDays(days)
		setExpiration(days * 24 * 60**2)
	end
	
	def setExpiration(seconds)
		setExpirationTimestamp(Time.now.gmtime.to_i + seconds)
	end
	
	def setExpirationTimestamp(timestamp)
		@expiration = Time.at(timestamp).strftime('%a, %d-%b-%Y %H:%M:%S GMT')
	end
	
	def get
		raise 'No expiration date has been specified' if @expiration == nil
		"#{@name}=#{@value}; Expires=#{@expiration}; Path=#{@path}; HttpOnly"
	end
end
