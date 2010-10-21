module WWWLib
	def self.writeJavaScript(input)
		newline = "\n"
		if !input.empty? && input[-1] != newline
			input += newline
		end
		output = "<script type=\"text/javascript\">\n//<![CDATA[\n#{input}//]]>\n</script>\n"
	end
end
