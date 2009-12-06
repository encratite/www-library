require 'cgi'

class HTTPRequest
	attr_reader :path, :pathString, :method, :accept, :address, :getInput, :postInput, :environment
	
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
		
		@getInput = CGI::parse(environment['QUERY_STRING'])
		@postInput = CGI::parse(environment['rack.input'].read())
		
		@cookies = {}
		cookieTokens = environment['HTTP_COOKIE'].split(';').map { |token| token.strip }
		cookieTokens.each do |token|
			assignmentTokens = token.split '='
			next if assignmentTokens.size != 2
			variable, value = assignmentTokens
			value = CGI::unescape value
			@cookies[variable] = value
		end
		
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
