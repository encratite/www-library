class SelectOption
	attr_reader :description, :value
	attr_accessor :selected
	def initialize(description, value, selected = false)
		@description = description
		@value = value
		@selected = selected
	end
end

class FormWriter
	def initialize(output, action)
		@output = output
		write "<form action=\"#{action}\" method=\"post\">\n"
	end
	
	def write(text)
		@output.concat text
	end
	
	def field(arguments = {})
		label = arguments[:label]
		type = arguments[:type] || :input
		inputType = arguments[:inputType] || 'text'
		name = arguments[:name] || label.downcase
		id = arguments[:id] || name
		value = arguments[:value]
		options = arguments[:options]
		onClick = arguments[:onClick]
		paragraph = arguments[:paragraph] || true
		radio = type == :radio
		checked = arguments[:checked] || false
		fieldClass = arguments[:class]
		
		if radio
			type = :input
			inputType = 'radio'
			fieldClass = inputType
		end
		
		if type == nil
			passwordString = 'password'
			type = label.downcase.include?(passwordString) ? passwordString : 'text'
		end
		
		extendedString = ''
		
		extensions =
		[
			['value', value],
			['onclick', onClick],
			['class', fieldClass],
		]
		
		extensions.each { |name, extension| extendedString += " #{name}=\"#{extension}\"" if extension != nil }
		
		write "<p>\n" if paragraph
		#write "<label for=\"#{id}\">#{label}:</label><br />\n" if !radio && label != nil
		
		gotList = !radio && label != nil
		if gotList
			write "<ul>\n"
			#write "<li><label for=\"#{id}\">#{label}:</label></li>\n"
			write "<li class=\"formLabel\">#{label}:</li>\n"
			write "<li>\n"
		end
		
		case type
		when :input
			if radio
				extendedString += ' checked="checked"' if checked
				write "<input type=\"#{inputType}\" name=\"#{name}\"#{extendedString} /> #{label}\n"
			else
				write "<input type=\"#{inputType}\" id=\"#{id}\" name=\"#{name}\"#{extendedString} />\n"
			end
		when :select
			raise 'No options have been specified for a select statement.' if options == nil
			write "<select id=\"#{id}\" name=\"#{name}\">\n"
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
		end
		
		if gotList
			write "</li>\n"
			write "</ul>\n"
		end
		
		write "</p>\n" if paragraph
	end

	def submitButton(description = 'Submit')
		write "<p>\n<input type=\"submit\" value=\"#{description}\" />\n</p>\n"
	end
	
	def endOfForm
		write "</form>\n"
	end
	
	def finish
		submitButton
		endOfForm
	end
end
