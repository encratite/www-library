require 'cgi'

class HTTPRequest
	attr_reader :path, :pathString, :method, :accept, :address, :getInput, :postInput, :cookies, :environment, :agent, :urlBase
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
		
		@agent = getAgent environment
		
		@urlBase = environment['rack.url_scheme'] + '://' + environment['HTTP_HOST']
	end
	
	def getAgent(environment)
		agent = environment['HTTP_USER_AGENT']
		return nil if agent == nil
		
		agents =
		[
			['Opera/', :opera],
			['MSIE 6.0;', :ie6],
			['MSIE 7.0;', :ie7],
			['MSIE 8.0;', :ie8],
			['Firefox/', :firefox],
			['Chrome/', :chrome],
		]
		
		agents.each do |string, symbol|
			return symbol if agent.index(string) != nil
		end
		
		return nil
	end
	
	def self.tokenisePath(path)
		tokens = path.split('/')
		tokens.shift if path.size > 0 && path[0] == '/'
		return tokens
	end
	
	def getPost(name)
		output = @postInput[name]
		return nil if output == nil
		return output[0]
	end
	
	def postIsSet(names)
		names.each { |name| return false if @postInput[name] == nil }
		return true
	end
end
