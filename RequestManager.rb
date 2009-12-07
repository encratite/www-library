base = 'site'

includes =
[
	'HTTPRequest',
	'HTTPReply',
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
		@handlers << RequestHandler.new(HTTPRequest.tokenisePath(path), handler)
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
				reply = HTTPReply.new "Unable to find \"#{request.pathString}\"."
				reply.plain
				reply.notFound
			else
				case output.class
					when Array
						contentType, content = output
						reply = HTTPReply.new content
						reply.contentType = contentType
					when String
						contentType = MIMEType::XHTML
						contentType = MIMEType::HTML if !request.accept.include?(contentType)
						reply = HTTPReply.new output
						reply.contentType = contentType
					when HTTPReply
						reply = output
					else
						reply = HTTPReply.new 'A handler returned an invalid type.'
						reply.plain
						reply.error
					end
				end
			end
		rescue => exception
			if hasDebugPrivilege request
				content = "An exception of type #{exception.class} occured:\n\n"
				content += exception.backtrace.join "\n"
			else
				content = 'An internal server error occured.'
			end
			
			reply = HTTPReply.new content
			reply.plain
			reply.error
		end
		
		reply.get
	end
end
