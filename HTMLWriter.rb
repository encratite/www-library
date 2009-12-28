class SelectOption
	attr_reader :description, :value
	attr_accessor :selected
	def initialize(description, value, selected = false)
		@description = description
		@value = value
		@selected = selected
	end
end

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
	
	def tag(tag, arguments, function = nil, useNewline = true)
		newline = "\n"
		writeNewline = lambda { write newline if useNewline }
		
		addId arguments
		
		argumentString = ''
		arguments.each { |key, value| argumentString += " #{key.to_s}=\"#{value}\"" }
		if function == nil
			write "<#{tag}#{argumentString} />"
		else
			write "<#{tag}#{argumentString}>"
			writeNewline.call
			data = function.call
			write data if data.class == String
			writeNewline.call if @lastCharacter != newline
			write "</#{tag}>"
		end
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
	
	def getName(label)
		return nil if label == nil
		label.scan(/[A-Za-z]/).join('')
	end
	
	def addId(arguments)
		arguments[:id] = getName arguments[:name] if arguments[:name] != nil && arguments[:id] == nil
	end
	
	def form(action, arguments = {}, &block)
		arguments[:method] = 'post'
		arguments[:action] = action
		tag('form', arguments, block)
	end
	
	def withLabel(label, &block)
		ul class: 'formLabel' do
			li { label }
			li { block.call }
		end
	end
	
	def field(type, label, name, value, arguments)
		arguments[:type] = type
		arguments[:name] = name
		arguments[:value] = value
		
		withLabel(label) do tag('input', arguments) end
	end
	
	def text(label, name, value = nil, arguments = {})
		field('text', label, name, value, arguments)
	end
	
	def password(label, name, value = nil, arguments = {})
		field('password', label, name, value, arguments)
	end
	
	def hidden(name, value = nil, arguments = {})
		arguments[:type] = 'hidden'
		arguments[:name] = name
		arguments[:value] = value
		
		tag('input', arguments)
	end
	
	def radio(label, name, value, checked = false, arguments = {})
		arguments[:type] = 'radio'
		arguments[:name] = name
		arguments[:value] = value
		arguments[:checked] = 'checked' if checked
		
		tag('input', arguments, nil, false)
		write " #{label}\n"
	end
	
	def select(name, options, arguments = {})
		function = lambda do
			gotASelection = false
			options.each do |option|
				currentArguments = {value: option.value}
				if option.selected
					raise 'You cannot specify more than one selected element in a <select> tag.' if gotASelection
					gotASelection = true
					currentArguments[:selected] = 'selected'
				end
				option currentArguments do option.description end
			end
		end
		arguments[:name] = name
		tag('select', arguments, function)
	end
	
	def textArea(label, name, value, arguments = {})
		function = lambda { value }
		arguments[:name] = name
		withLabel label do tag('textarea', arguments, function) end
	end
	
	def submit(description = 'Submit')
		arguments[:type] = 'submit'
		arguments[:value] = description
		
		p do
			tag('input', arguments)
		end
	end
	
	self.createMethods [
		'a',
		'b',
		'div',
		'li',
		'option',
		'p',
		'table',
		'td',
		'tr',
		'ul',
	]
end
