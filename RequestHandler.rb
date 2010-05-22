require 'www-library/HTTPRequest'
require 'www-library/MenuEntry'
require 'www-library/string'
require 'www-library/RequestManager'
require 'www-library/MIMEType'

class RequestHandler
	attr_reader :name, :isMenu, :menuDescription, :menuCondition
	attr_accessor :parent
	
	NoArguments = 0..0
	TrueCondition = lambda { |request| true }
	
	@@bufferedObjects = []
	
	def initialize(name)
		@name = name
		@isMenu = false
		@menuDescription = nil
		@menuCondition = TrueCondition
		@handler = nil
		@argumentCount = NoArguments
		@children = []
		@parent = nil
	end
	
	def self.newBufferedObjectsGroup
		@@bufferedObjects = []
	end
	
	def self.getBufferedObjects
		output = @@bufferedObjects
		self.newBufferedObjectsGroup
		return output
	end
	
	def setHandler(handler, argumentCount = nil)
		if argumentCount == nil
			argumentCount = NoArguments
		elsif argumentCount.class == Fixnum
			argumentCount = argumentCount..argumentCount
		end
		@handler = handler
		@argumentCount = argumentCount
		return nil
	end
	
	def setMenuData(menuDescription, menuCondition)
		@isMenu = true
		@menuDescription = menuDescription
		@menuCondition = menuCondition
		return nil
	end
	
	def self.handler(name, handler, argumentCount = nil)
		output = RequestHandler.new(name)
		output.setHandler(handler, argumentCount)
		@@bufferedObjects << output
		return output
	end
	
	def self.menu(menuDescription, name, handler, argumentCount = nil, menuCondition = TrueCondition)
		output = RequestHandler.new(name)
		output.setHandler(handler, argumentCount)
		output.setMenuData(menuDescription, menuCondition)
		@@bufferedObjects << output
		return output
	end
	
	def add(newRequestHandler)
		newRequestHandler.parent = self
		@children << newRequestHandler
		return nil
	end
	
	def getRemainingPath(path)
		return path if @name == nil && path.empty?
		return path[1..-1] if !path.empty? && @name == path[0]
		return nil
	end
	
	def match(request, path = request.path)
		arguments = getRemainingPath(path)
		return nil if arguments == nil
		
		@children.each do |child|
			output = child.match(request, arguments)
			return output if output != nil
		end
		
		return nil if @handler == nil
		
		if !(@argumentCount === arguments.size)
			message = 'Invalid argument count.'
			raise RequestManager::Exception.new([MIMEType::Plain, message])
		end
		request.arguments = arguments
		request.handler = self
		return @handler.(request)
	end
	
	def description
		return "#{@name.inspect} -> #{@parent == nil ? 'no parent' : @parent.name.inspect}, children: #{@children.size}"
	end
	
	def getSubMenu(previousPath)
		previousPath << @name if @name != nil
		output = []
		@children.each do |child|
			next if !child.isMenu
			output << MenuEntry.new(previousPath + [child.name], child.menuDescription, child.menuCondition)
		end
		return output
	end
	
	def getParents
		output = []
		currentHandler = self
		while true
			output << currentHandler
			break if currentHandler.parent == nil
			currentHandler = currentHandler.parent
		end
		return output.reverse
	end
	
	def getMenu
		previousPath = []
		output = []
		handlers = getParents
		handlers.each do |handler|
			menu = handler.getSubMenu(previousPath)
			output << menu if !menu.empty?
			break if handler == self
		end
		return output
	end
	
	def getPath(*arguments)
		elements = getParents.map { |handler| handler.name }.compact + arguments
		return slashify elements
	end
end
