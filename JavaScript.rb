module WWWLib
	def self.writeJavaScript(input)
		output = "<script type=\"text/javascript\">\n//<![CDATA[\n#{input}\n//]]>\n</script>\n"
	end
end
