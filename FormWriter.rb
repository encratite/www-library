class FormWriter
	def initialize(output, action)
		@output = output
		@output.concat "<form action=\"#{action}\" method=\"post\">\n"
	end
	
	def label(arguments = {})
		label = arguments[:label] || 'Description'
		type = arguments[:type]
		name = arguments[:name] || label.downcase
		id = arguments[:id] || name
		
		if type == nil
			passwordString = 'password'
			type = label.downcase.include? passwordString ? passwordString : 'text'
		end
		@output.concat "<p>\n<label for=\"#{id}\">#{label}:</label><br />\n<input type=\"#{type}\" id=\"#{id}\" name=\"#{name}\" />\n</p>\n"
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
