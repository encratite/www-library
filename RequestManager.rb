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
	def initialize(requestClass = HTTPRequest)
		@handlers = []
		@requestClass = requestClass
	end
	
	def addHandler(handler)
		@handlers << handler
	end
	
	def handleRequest(environment)
		request = @requestClass.new environment
		output = nil
		
		begin
			@handlers.each do |handler|
				output = handler.match request
				break if output != nil
			end
		
			case output
			when NilClass
				reply = HTTPReply.new "Unable to find \"#{request.pathString}\"."
				reply.plain
				reply.notFound
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
				if hasDebugPrivilege request
					content = "A handler returned the invalid type #{output.class}."
				else
					content = 'A handler returned an invalid type.'
				end
				reply = HTTPReply.new content
				reply.plain
				reply.error
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
