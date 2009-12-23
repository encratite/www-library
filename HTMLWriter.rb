class HTMLWriter
	def initialize(output)
		@output = output
		@lastCharacter = nil
	end
	
	def write(text)
		@output.concat text
		@lastCharacter = text[-1]
		return nil
	end
	
	def tag(tag, arguments, block, useNewline = true)
		newline = "\n"
		writeNewline = lambda { write newline if useNewline }
		argumentString = ''
		arguments.each { |key, value| argumentString += " #{key.to_s}=\"#{value}\"" }
		write "<#{tag}#{argumentString}>"
		writeNewline.call
		data = block.call
		write data if data.class == String
		writeNewline.call if @lastCharacter != newline
		write "</#{tag}>"
		writeNewline.call
		return nil
	end
	
	def self.createMethods(methods)
		methods.each do |method|
			send :define_method, method do |arguments = {}, &block|
				tag(method, arguments, block)
			end
		end
	end
	
	self.createMethods [
		'a',
		'b',
		'div',
		'li',
		'p',
		'table',
		'td',
		'tr',
		'ul',
	]
end
