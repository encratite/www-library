require 'site/HTTPRequest'

class RequestHandler
	attr_reader :name, :isMenu, :menuDescription, :menuCondition
	attr_accessor :manager, :handler, :parent
	
	NoArguments = 0..0
	TrueCondition = lambda { |request| true }
	
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
	
	def setHandler(handler, argumentCount = NoArguments)
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
	
	def self.menu(menuDescription, name, handler, argumentCount = NoArguments, menuCondition = TrueCondition)
		output = RequestHandler.new(name)
		output.setHandler(handler, argumentCount)
		output.setMenuData(menuDescription, menuCondition)
		return output
	end
	
	def add(newRequestHandler)
		newRequestHandler.parent = self
		@children << newRequestHandler
		return nil
	end
	
	def getRemainingPath(path)
		return path if @name == nil
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
		
		return nil if @handler == nil
		
		request.arguments = remainingPath
		return @handler.(request)
	end
	
	def getMenuStructure
		return nil if @isMenu == false
		output = MenuEntry.new(@name, @menuDescription, @menuCondition)
		@children.each do |child|
			subMenu = child.getMenuStructure
			output.add(subMenu) if subMenu != nil
		end
		return output
	end
end

class MenuEntry
	attr_reader :description, :path, :condition, :children
	
	def initialize(path, description, condition)
		@path = path
		@description = description
		@condition = condition
		@children = []
	end
	
	def add(child)
		@children << child
	end
end
