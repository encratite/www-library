class RequestHandler
	attr_reader :path, :handler
	
	def initialize(path, handler)
		@path = path
		@handler = handler
	end
	
	def match(request)
		@handler.(request) if @path == request.path[0..(@path.size - 1)]
	end
end
