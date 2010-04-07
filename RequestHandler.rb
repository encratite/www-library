require 'site/HTTPRequest'
require 'site/MenuEntry'

class RequestHandler
	attr_reader :name, :isMenu, :menuDescription, :menuCondition
	attr_accessor :parent
	
	#debugging
	attr_reader :children
	
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
		puts 'menu!'
		output = RequestHandler.new(name)
		output.setHandler(handler, argumentCount)
		output.setMenuData(menuDescription, menuCondition)
		@@bufferedObjects << output
		return output
	end
	
	def add(newRequestHandler)
		newRequestHandler.parent = self
		@children << newRequestHandler
		puts "Added: #{newRequestHandler.menuDescription}"
		@children.each do |child|
			#puts child.menuDescription
		end
		return nil
	end
	
	def getRemainingPath(path)
		return path if @name == nil && path.empty?
		return path[1..-1] if !path.empty? && @name == path[0]
		return nil
	end
	
	def match(request, path = request.path)
		remainingPath = getRemainingPath(path)
		return nil if remainingPath == nil
		
		@children.each do |child|
			output = child.match(request, remainingPath)
			return output if output != nil
		end
		
		return nil if @handler == nil || !(@argumentCount === remainingPath.size)
		
		request.arguments = remainingPath
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
			#puts "Adding #{child.menuDescription}"
			output << MenuEntry.new(previousPath + [child.name], child.menuDescription, child.menuCondition)
		end
		#puts "getSubMenu: #{previousPath.inspect} -> #{output.size}"
		return output
	end
	
	def getParents
		output = []
		currentHandler = self
		#puts "Parents:"
		while true
			#puts currentHandler.description
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
			#puts "Calling getSubMenu for #{handler.description}"
			menu = handler.getSubMenu(previousPath)
			output << menu if !menu.empty?
			break if handler == self
		end
		return output
	end
end
