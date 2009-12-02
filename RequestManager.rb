require 'site/HTTPReplyCode'
require 'site/RequestHandler'
require 'site/MIMEType'

class RequestManager
	def initialize()
		@handlers = []
	end
	
	def addHandler(path, handler)
		@handlers <<= RequestHandler.new(path.split('/'), handler)
	end
	
	def handleRequest(request)
		output = nil
		@handlers.each do |handler|
			output = handler.match request
			break if output != nil
		end
		
		if output == nil
			replyCode = HTTPReplyCode.NotFound
			contentType = MIMEType.Plain
			content = 'Unable to find ' + request.pathString
		else
			replyCode = HTTPReplyCode.Ok
			if output.class == Array
				contentType, content = output
			else
				contentType = MIMEType.XHTML
				contentType = MIMEType.HTML if !request.accept.include?(contentType)
				content = output
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
