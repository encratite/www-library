require 'www-library/HTTPReplyCode'
require 'www-library/MIMEType'
require 'www-library/Cookie'

module WWWLib
	class HTTPReply
		attr_accessor :replyCode, :contentType, :content
		
		def initialize(content)
			raise "Invalid content class #{content.class} in a HTTP reply" if content.class != String
			@replyCode = HTTPReplyCode::Ok
			@content = content
			@contentType = MIMEType::HTML
			@fields = {}
			@cookies = []
		end
		
		def plain
			@contentType = MIMEType::Plain
		end
		
		def notFound
			@replyCode = HTTPReplyCode::NotFound
		end
		
		def error
			@replyCode = HTTPReplyCode::InternalServerError
		end
		
		def addCookie(cookie)
			@cookies << cookie
		end
		
		def deleteCookie(name, path)
			cookie = Cookie.new(name, '', path)
			cookie.delete
			@cookies << cookie
		end
		
		def setField(field, value)
			@fields[field] = value
		end
		
		def get
			@fields['Content-Type'] = @contentType
			@fields['Content-Length'] = @content.size.to_s
			@fields['Set-Cookie'] = @cookies.map { |cookie| cookie.get } if !@cookies.empty?
			
			output =
			[
				@replyCode,
				@fields,
				[@content]
			]
			
			return output
		end
		
		def self.refer(url)
			reply = HTTPReply.new ''
			reply.replyCode = HTTPReplyCode::Found
			reply.setField('Location', url)
			return reply
		end
		
		def self.localRefer(request, path)
			return self.refer(request.urlBase + path)
		end
	end
end
