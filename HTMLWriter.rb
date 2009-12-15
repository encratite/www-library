class HTMLWriter
	def initialize(output)
		@output = output
	end
	
	def write(text)
		@output.concat text
	end
	
	def tag(tag, arguments, block, useNewline = false)
		newline = "\n"
		argumentString = ''
		arguments.each { |key, value| argumentString += " #{key.to_s}=\"#{value}\"" }
		write "<#{tag}#{argumentString}>"
		write newline if useNewline
		block.call
		write "</#{tag}>"
		write newline if useNewline
	end
	
	def div(arguments = {}, &block)
		tag('div', arguments, block, true)
	end
	
	def p(arguments = {}, &block)
		tag('p', arguments, block)
	end
	
	def table(arguments = {}, &block)
		tag('table', arguments, block, true)
	end
	
	def tr(arguments = {}, &block)
		tag('tr', arguments, block, true)
	end
	
	def td(arguments = {}, &block)
		tag('td', arguments, block)
	end
end
