class RequestHandler
	attr_reader :path, :handler
	
	def initialize(path, handler)
		@path = path
		@handler = handler
	end
	
	def match(request)
		path = request.path
		return false if path.size < @path.size
		path.size.times do |i|
			return nil if path[i] != @path[i]
		end
		return @handler.(request)
	end
end
