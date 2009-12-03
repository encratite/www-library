class FormWriter
	def initialize(output, action)
		@output = output
		@output.concat "<form action=\"#{action}\" method=\"post\">\n"
	end
	
	def label(label, type = 'text', name = label.downcase, id = name)
		passwordString = 'password'
		type = passwordString if label.downcase.include? passwordString
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
