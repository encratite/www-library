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
	class Exception
		attr_reader :content
		
		def initialize(content)
			@content = content
		end
	end
	
	def initialize(requestClass = HTTPRequest)
		@handlers = []
		@requestClass = requestClass
	end
	
	def addHandler(handler)
		@handlers << handler
	end
	
	def getExceptionLine(exception)
		data = exception.backtrace[0]
		tokens = data.split ':'
		drive = tokens[0]
		if drive.length == 1
			newTokens = tokens[1..-1]
			first = newTokens[0]
			first = drive + first
			tokens = newTokens
		end
		path = tokens[0]
		lineNumber = tokens[1].to_i - 1
		file = File.new(path, 'r')
		lines = file.readlines
		file.close
		line = lines[lineNumber].delete "\t"
		return line
	end
	
	def processOutput(output)
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
	end
	
	def handleRequest(environment)
		request = @requestClass.new environment
		output = nil
		
		begin
			@handlers.each do |handler|
				output = handler.match request
				break if output != nil
			end
		
			processOutput output
			
		rescue RequestManager::Exception => exception
			processOutput exception.content
			
		else => exception
			if hasDebugPrivilege request
				content = "An exception of type #{exception.class} occured:\n\t#{exception.message}\n\n"
				content += "On the following line:\n\t" + getExceptionLine(exception) + "\n"
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
