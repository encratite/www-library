require 'www-library/HTTPRequest'
require 'www-library/HTTPReply'
require 'www-library/HTTPReplyCode'
require 'www-library/RequestHandler'
require 'www-library/MIMEType'
require 'www-library/debug'

class RequestManager
	class Exception < Exception
		attr_reader :content
		
		def initialize(content)
			@content = content
		end
	end
	
	attr_writer :exceptionMessageHandler
	
	def initialize(requestClass = HTTPRequest)
		@handlers = []
		@requestClass = requestClass
		@exceptionMessageHandler = method(:defaultExceptionMessageHandler)
	end
	
	def addHandler(handler)
		@handlers << handler
		return nil
	end
	
	def getExceptionLine(exception)
		data = exception.backtrace[0]
		tokens = data.split ':'
		drive = tokens[0]
		if drive.length == 1
			newTokens = tokens[1..-1]
			newTokens[0] = drive + ':' + newTokens[0]
			tokens = newTokens
		end
		path = tokens[0]
		lineNumber = tokens[1].to_i - 1
		begin
			file = File.new(path, 'r')
			lines = file.readlines
			file.close
			line = lines[lineNumber].delete "\t"
			return line
		rescue Errno::ENOENT
			return "<Unable to retrieve code>\n"
		end
	end
	
	def processOutput(request, output)
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
		
		return reply
	end
	
	def getDebugMessage(exception)
		debugMessage = "An exception of type #{exception.class} occured:\n\n"
		debugMessage.concat "\t#{exception.message}\n\n"
		debugMessage.concat "On the following line:\n"
		debugMessage.concat "\t" + getExceptionLine(exception) + "\n"
		debugMessage.concat exception.backtrace.join "\n"
		return debugMessage
	end
	
	def defaultExceptionMessageHandler(message)
		puts message
	end
	
	def processError(request, environment, exception)
		request = HTTPRequest.new(environment) if request == nil
		
		fullOutput = getDebugMessage(exception)
			
		if hasDebugPrivilege request
			content = fullOutput
		else
			content = 'An internal server error occured.'
		end
		
		@exceptionMessageHandler.call(fullOutput)
		
		reply = HTTPReply.new content
		reply.plain
		reply.error
		
		return reply
	end
	
	def handleRequest(environment)
		begin
			request = nil
			request = @requestClass.new(environment)
		
			output = nil

			@handlers.each do |handler|
				output = handler.match request
				break if output != nil
			end
		
			reply = processOutput(request, output)
			
		rescue RequestManager::Exception => exception
			reply = processOutput(request, exception.content)
			
		rescue RuntimeError => exception
			reply = processError(request, environment, exception)
			
		rescue Exception => exception
			reply = processError(request, environment, exception)
			
		rescue => exception
			reply = processError(request, environment, exception)
			
		end
		
		output = reply.get
		return output
	end
end
