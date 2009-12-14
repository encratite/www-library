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
		tag('div', arguments, block)
	end
	
	def p(arguments = {}, &block)
		tag('p', arguments, block)
	end
end

output = ''
writer = HTMLWriter.new output
writer.div do
	writer.write 'check this out '
	writer.p id: 'wef' do
		writer.write 'lol hay'
	end
end

puts output
