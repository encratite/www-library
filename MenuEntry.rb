class MenuEntry
	attr_accessor :path
	attr_reader :description, :condition, :children
	
	def initialize(path, description, condition)
		if path.class == Array
			@path = path
		else
			@path = [path]
		end
		@description = description
		@condition = condition
		@children = []
	end
	
	def add(child)
		child.path = @path + child.path
		@children << child
	end
end
