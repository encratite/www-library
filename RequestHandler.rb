require 'site/HTTPRequest'
require 'site/MenuEntry'

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
	
	def match(request, path = request.path, previousPath = [], menu = [])
		newPath = previousPath
		newPath += [@name] if @name != nil
		remainingPath = getRemainingPath(path)
		
		return nil if remainingPath == nil
		
		@children.each do |child|
			output = child.match(request, remainingPath, newPath, menu.dup)
			return output if output != nil
		end
		
		return nil if @handler == nil || !(@argumentCount === remainingPath.size)
		
		request.arguments = remainingPath
		request.handler = self
		if @isMenu
			MenuEntry.new(newPath, @menuDescription, @menuCondition)
		end
		return @handler.(request)
	end
	
	def getMenuStructure(previousPath = [])
		newPath = previousPath
		newPath += [@name] if @name != nil
		if !@isMenu
			output = []
			@children.each do |child|
				subMenu = child.getMenuStructure newPath
				output += subMenu
			end
			return output
		else
			output = MenuEntry.new(newPath, @menuDescription, @menuCondition)
			@children.each do |child|
				subMenu = child.getMenuStructure newPath
				subMenu.each do |entry|
					output.add(entry) if subMenu != nil
				end
			end
			return [output]
		end
	end
end
