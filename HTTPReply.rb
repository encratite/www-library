require 'site/HTTPReplyCode'
require 'site/MIMEType'
require 'site/Cookie'

class HTTPReply
	attr_writer :replyCode, :contentType, :content
	
	def initialize(content)
		@replyCode = HTTPReplyCode::Ok
		@content = content
		@contentType = MIMEType::HTML
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
	
	def get
		fields =
		{
			'Content-Type' => @contentType,
			'Content-Length' => @content.size.to_s
		}
		
		
		fields['Set-Cookie'] = @cookies.map { |cookie| cookie.get } if !@cookies.empty?
		
		output =
		[
			@replyCode,
			fields,
			[@content]
		]
		
		output
	end
end
