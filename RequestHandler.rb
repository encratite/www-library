require 'site/HTTPRequest'

class RequestHandler
	attr_reader :path, :handler
	
	def initialize(path, handler, argumentCount = nil)
		@path = HTTPRequest.tokenisePath(path)
		@handler = handler
		
		case argumentCount
		when NilClass
			@argumentRange = 0..0
		when Fixnum
			@argumentRange = argumentCount..argumentCount
		when Range
			@argumentRange = argumetnCount
		else
			raise "Invalid argument count type specified: #{argumentCount.class}"
		end
	end
	
	def match(request)
		path = request.path
		arguments = path[@path.size..-1]
		if @path == path[0..(@path.size - 1)] && @argumentRange === arguments.size
			request.arguments = arguments
			@handler.(request)
		end
	end
end
