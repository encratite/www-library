class ScriptEntry
	attr_reader :type, :source
	def initialize(type, source)
		@type = type
		@source = source
	end
end

class SiteGenerator
	def initialize
		@stylesheets = []
		@scripts = []
		@inlineStylesheets = []
	end
	
	def addStylesheet(stylesheet)
		@stylesheets << stylesheet
	end
	
	def addScript(source, type = 'text/javascript')
		@scripts << ScriptEntry.new(type, source)
	end
	
	def addInlineStylesheet(code)
		@inlineStylesheets << code
	end
	
	def head(title)

		output =
<<END
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
END

		@stylesheets.each do |stylesheet|
			output.concat "<link rel=\"stylesheet\" type=\"text/css\" media=\"screen\" href=\"#{stylesheet}\" />\n"
		end
		
		@inlineStylesheets.each do |stylesheet|
			output.concat <<END
<style type="text/css" media="screen">
/*<![CDATA[*/
#{stylesheet}
/*]]>*/
</style>
END
		end
		
		@scripts.each do |script|
			output.concat "<script type=\"#{script.type}\" src=\"#{script.source}\"></script>\n"
		end

		output.concat <<END
<title>#{title}</title>
</head>
<body>
END

		return output
	end
	
	def foot
		output =
<<END
</body>
</html>
END
		return output
	end
	
	def get(title, content)
		return head(title) + content + foot
	end
end
