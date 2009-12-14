class SelectOption
	attr_reader :description, :value, :selected
	def iniitalize(description, value, selected = false)
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
		inputType = arguments[:inputType]
		name = arguments[:name] || label.downcase
		id = arguments[:id] || name
		value = arguments[:value]
		options = arguments[:options]
		onClick = arguments[:onClick]
		paragraph = arguments[:paragraph] || true
		radio = type == :radio
		checkd = arguments[:checked] || false
		
		if radio
			type = :input
			inputType = 'radio'
		end
		
		if type == nil
			passwordString = 'password'
			type = label.downcase.include?(passwordString) ? passwordString : 'text'
		end
		
		extendedString = ''
		extendedString += " value=\"#{value}\"" if value != nil
		extendedString += " onclick=\"#{onClick}\"" if onClick != nil
		
		output = ''
		write "<p>\n" if paragraph
		output = "<label for=\"#{id}\">#{label}:</label><br />\n" if !radio && label != nil
		case type
		when :input
			if radio
				extendedString += ' checked="checked"' if checked
				write "<input type=\"#{type}\" name=\"#{name}\"#{extendedString} /> #{label}\n"
			else
				write "<input type=\"#{type}\" id=\"#{id}\" name=\"#{name}\"#{extendedString} />\n"
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
		write "</p>\n" if paragraph
		@output.concat output
	end

	def submitButton
		@output.concat <<END
<p>
<input type="submit" />
</p>
END
	end
	
	def endOfForm
		@output.concat "</form>\n"
	end
	
	def finish
		submitButton
		endOfForm
	end
end
