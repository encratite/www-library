base = 'site'

includes =
[
	'HTTPRequest',
	'HTTPReplyCode',
	'RequestHandler',
	'MIMEType',
	'debug'
]

includes.each { |name| require base + '/' + name }

class RequestManager
	def initialize()
		@handlers = []
	end
	
	def addHandler(path, handler)
		@handlers << RequestHandler.new(HTTPRequest.tokenisePath(path), method(handler))
	end
	
	def handleRequest(environment)
		request = HTTPRequest.new environment
		output = nil
		
		begin
			@handlers.each do |handler|
				output = handler.match request
				break if output != nil
			end
		
			if output == nil
				replyCode = HTTPReplyCode::NotFound
				contentType = MIMEType::Plain
				content = "Unable to find \"#{request.pathString}\"."
			else
				replyCode = HTTPReplyCode::Ok
				if output.class == Array
					contentType, content = output
				else
					contentType = MIMEType::XHTML
					contentType = MIMEType::HTML if !request.accept.include?(contentType)
					content = output
				end
			end
		rescue => exception
			replyCode = HTTPReplyCode::InternalServerError
			contentType = MIMEType::Plain
			
			if hasDebugPrivilege request
				content = "An exception of type #{exception.class} occured:\n\n"
				content += exception.backtrace.join "\n"
			else
				content = 'An internal server error occured.'
			end
		end
		
		fields =
		{
			'Content-Type' => contentType,
			'Content-Length' => content.size.to_s
		}
		
		output =
		[
			replyCode,
			fields,
			[content]
		]
		
		return output
	end
end
