require 'cgi'

class HTTPRequest
	attr_reader :path, :pathString, :method, :accept, :address, :input, :environment
	
	def initialize(environment)
		@pathString = environment['REQUEST_PATH']
		pathTokens = HTTPRequest.tokenisePath @pathString
		@path = pathTokens.map { |token| CGI.unescape(token) }
		
		requestMethods =
		{
			'GET' => :get,
			'POST' => :post
		}
		
		@method = requestMethods[environment['REQUEST_METHOD']]
		
		@accept = []
		environment['HTTP_ACCEPT'].split(', ').each do |token|
			@accept << token.split(';')[0]
		end
		
		@address = environment['REMOTE_ADDR']
		
		@input = CGI::parse(environment['rack.input'].read())
		
		@environment = environment
	end
	
	def self.tokenisePath(path)
		tokens = path.split('/')
		tokens.shift if path.size > 0 && path[0] == '/'
		return tokens
	end
	
	def getInput(name)
		output = @input[name]
		return nil if output == nil
		return output[0]
	end
	
	def isSet(*names)
		names.each do |name|
			return false if @input[name] == nil
		end
		return true
	end
end
