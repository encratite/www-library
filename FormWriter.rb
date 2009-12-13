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
		@output.concat "<form action=\"#{action}\" method=\"post\">\n"
	end
	
	def field(arguments = {})
		label = arguments[:label] || 'Description'
		type = arguments[:type] || :input
		inputType = arguments[:inputType]
		name = arguments[:name] || label.downcase
		id = arguments[:id] || name
		value = arguments[:value]
		options = arguments[:options]
		
		if type == nil
			passwordString = 'password'
			type = label.downcase.include?(passwordString) ? passwordString : 'text'
		end
		
		valueString = value == nil ? '' : "value=\"#{value}\""
		
		output = "<p>\n<label for=\"#{id}\">#{label}:</label><br />\n"
		case type
		when :input
			output += "<input type=\"#{type}\" id=\"#{id}\" name=\"#{name}\" #{valueString}/>\n"
		when :select
			raise 'No options have been specified for a select statement.' if options == nil
			output += "<select id=\"#{id}\" name=\"#{name}\">\n"
			gotASelection = false
			options.each do |option|
				if option.selected
					raise 'You cannot specify more than one selected element in a <select> tag.' if gotASelection
					gotASelection = true
					selectedString = ' selected="selected"'
				else
					selectedString = ''
				end
				output += "<option value=\"#{option.value}\"#{selectedString}>#{option.description}</option>\n"
			end
			output += "</select>\n"
		end
		output += "</p>\n"
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
