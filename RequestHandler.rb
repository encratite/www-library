require 'site/HTTPRequest'

class RequestHandler
	attr_reader :name, :isMenu, :menuDescription
	
	NoArguments = 0..0
	TrueCondition = { |request| true }
	
	def initialize(name)
		@name = name
		@isMenu = nil
		@menuDescription = nil
		@handler = nil
		@argumentCount = NoArguments
		@children = []
		@condition = TrueCondition
	end
	
	def setHandler(handler, argumentCount = NoArguments, condition = TrueCondition)
		@handler = handler
		@argumentCount = argumentCount
		@condition = condition
		return nil
	end
	
	def self.menu(name, handler, argumentCount = NoArguments, condition = TrueCondition)
		output = Requesthandler.new(name)
		output.setHandler(handler, argumentCount, condition)
		return output
	end
	
	def add(newRequestHandler)
		@children << newRequestHandler
		return nil
	end
	
	def match(request, path = request.path)
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
		arguments = path[1..-1]
		if target == @name && @argumentRange === arguments.size && @condition.(request)
			request.arguments = arguments
			return @handler.(request)
		end
		
		return nil
	end
end
