require 'site/HTTPRequest'

class RequestHandler
	attr_reader :name, :isMenu, :menuDescription
	
	NoArguments = 0..0
	
	def initialize(name)
		@name = name
		@isMenu = nil
		@menuDescription = nil
		@handler = nil
		@argumentCount = NoArguments
		@children = []
	end
	
	def setHandler(handler, argumentCount = NoArguments)
		@handler = handler
		@argumentCount = argumentCount
		return nil
	end
	
	def self.menu(name, handler, argumentCount = NoArguments)
		output = Requesthandler.new(name)
		output.setHandler(handler, argumentCount)
		return output
	end
	
	def match(request)
		path = request.path
		#puts "Comparing #{path} to #{getPath}"
		arguments = path[@path.size..-1]
		if @path == path[0..(@path.size - 1)] && @argumentRange === arguments.size
			request.arguments = arguments
			@handler.(request)
		end
	end
end
