require 'cgi'

class HTTPRequest
	attr_reader :path, :pathString, :method, :accept, :address, :getInput, :postInput, :cookies, :environment
	attr_accessor :arguments
	
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
		cookies = environment['HTTP_COOKIE']
		if cookies != nil
			cookieTokens = cookies.split(';').map { |token| token.strip }
			cookieTokens.each do |token|
				assignmentTokens = token.split '='
				next if assignmentTokens.size != 2
				variable, value = assignmentTokens
				value = CGI::unescape value
				@cookies[variable] = value
			end
		end
		
		@environment = environment
	end
	
	def self.tokenisePath(path)
		tokens = path.split('/')
		tokens.shift if path.size > 0 && path[0] == '/'
		tokens
	end
	
	def getPost(name)
		output = @postInput[name]
		return nil if output == nil
		output[0]
	end
	
	def postIsSet(names)
		names.each { |name| return false if @postInput[name] == nil }
		true
	end
end
