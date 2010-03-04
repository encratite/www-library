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
	
	def add(newRequestHandler)
		@children << newRequestHandler
		return nil
	end
	
	def match(request, path = request.path)
		path = request.path
		#puts "Comparing #{path} to #{getPath}"
		arguments = path[@path.size..-1]
		if @path == path[0..(@path.size - 1)] && @argumentRange === arguments.size
			request.arguments = arguments
			@handler.(request)
		end
		
		path = request.path
		
		children.each do |child|
			output = child.match(request, path)
			return output if output != nil
		end
		
		return nil if @handler == nil
		
		if path.empty?
			return @handler.(request) if @name == nil
			return nil
		end
		
		target = path[0]
		
	end
end
