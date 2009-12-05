class SiteGenerator
	def initialize
		@stylesheets = []
	end
	
	def addStylesheet(stylesheet)
		@stylesheets << stylesheet
	end
	
	def head(title)

		output =
<<END
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
END

		@stylesheets.each do |stylesheet|
			output += "<link rel=\"stylesheet\" type=\"text/css\" media=\"screen\" href=\"#{stylesheet}\" />\n"
		end

		output +=
<<END
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
