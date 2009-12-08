require 'htmlentities'

class HTMLEntities
	HtmlCoder = HTMLEntities.new
	
	def self.encode(input)
		HtmlCoder.encode input
	end
end
