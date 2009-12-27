require 'site/HTMLWriter'

class SelectOption
	attr_reader :description, :value
	attr_accessor :selected
	def initialize(description, value, selected = false)
		@description = description
		@value = value
		@selected = selected
	end
end

class FormWriter < HTMLWriter
	def initialize(output, action, arguments = {}, &block)
		super output
		arguments[:method] = 'post'
		arguments[:action] = action
		function = lambda do
			block.call
			submitButton
		end
		tag('form', arguments, function)
	end
	
	def getName(label)
		return nil if label == nil
		label.scan(/[A-Za-z]/).join('')
	end
	
	def field(arguments = {})
		label = arguments[:label]
		type = arguments[:type] || :input
		inputType = arguments[:inputType] || 'text'
		name = arguments[:name] || getName(label)
		id = arguments[:id]
		value = arguments[:value]
		options = arguments[:options]
		onClick = arguments[:onClick]
		paragraph = arguments[:paragraph]
		paragraph = true if paragraph == nil
		radio = type == :radio
		checked = arguments[:checked] || false
		fieldClass = arguments[:class]
		ulId = arguments[:ulId]
		
		id = name if id == nil && !radio
		
		if radio
			type = :input
			inputType = 'radio'
			fieldClass = inputType
		end
		
		if type == nil
			passwordString = 'password'
			type = label.downcase.include?(passwordString) ? passwordString : 'text'
		end
		
		additionalTags =
		[
			['class', fieldClass],
			['name', name],
			['id', id],
			['onclick', onClick],
		]
		
		additionalTags << ['value', value] if type != :textarea
		additionalTags << ['checked', 'checked'] if radio && checked
		
		tagString = ''
		additionalTags.each { |name, extension| tagString += " #{name}=\"#{extension}\"" if extension != nil }
		
		gotList = !radio && label != nil
		paragraph = false if gotList
		
		write "<p>\n" if paragraph
		
		if gotList
			ulIdString = ulId == nil ? '' : " id=\"#{ulId}\""
			write "<ul class=\"formLabel\"#{ulIdString}>\n"
			write "<li>\n#{label}:\n</li>\n"
			write "<li>\n"
		end
		
		case type
		when :input
			if radio
				write "<input type=\"#{inputType}\"#{tagString} /> #{label}\n"
			else
				write "<input type=\"#{inputType}\"#{tagString} />\n"
			end
		when :select
			raise 'No options have been specified for a select statement.' if options == nil
			write "<select#{tagString}>\n"
			gotASelection = false
			options.each do |option|
				if option.selected
					raise 'You cannot specify more than one selected element in a <select> tag.' if gotASelection
					gotASelection = true
					selectedString = ' selected="selected"'
				else
					selectedString = ''
				end
				write "<option value=\"#{option.value}\"#{selectedString}>#{option.description}</option>\n"
			end
			write "</select>\n"
		when :textarea
			write "<textarea rows=\"10\" cols=\"30\"#{tagString}>#{value}</textarea>\n"
		end
		
		if gotList
			write "</li>\n"
			write "</ul>\n"
		end
		
		write "</p>\n" if paragraph
		
		return nil
	end
	
	def text(arguments = {})
		arguments[:type] = :input
		field arguments
	end
	
	def password(arguments = {})
		arguments[:type] = :input
		arguments[:inputType] = :password
		field arguments
	end
	
	def hidden(arguments = {})
		arguments[:type] = :input
		arguments[:inputType] = :hidden
		field arguments
	end
	
	def select(arguments = {})
		arguments[:type] = :select
		field arguments
	end
	
	def textarea(arguments = {})
		arguments[:type] = :textarea
		field arguments
	end
	
	def radio(arguments = {})
		arguments[:type] = :radio
		field arguments
	end

	def submitButton(description = 'Submit')
		write "<p>\n<input type=\"submit\" value=\"#{description}\" />\n</p>\n"
	end
	
	def submit
		submitButton
	end
end
