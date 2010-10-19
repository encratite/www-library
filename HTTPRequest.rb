require 'cgi'

module WWWLib
	class HTTPRequest
		attr_reader :path, :pathString, :method, :accept, :address, :getInput, :rawInput, :postInput, :cookies, :environment, :agent, :urlBase
		attr_accessor :arguments, :handler
		
		UTF8BOM = "\xEF\xBB\xBF"
		
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
			accept = environment['HTTP_ACCEPT']
			if accept != nil
				accept.split(', ').each do |token|
					@accept << token.split(';')[0]
				end
			end
			
			@address = environment['HTTP_X_REAL_IP']
			#workaround for non-proxied access
			if @address == nil
				@address = environment['REMOTE_ADDR']
			end
			
			@getInput = CGI::parse(environment['QUERY_STRING'])
			@rawInput = environment['rack.input'].read
			processInput
			@postInput = CGI::parse(@rawInput)
			
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
			
			scheme = environment['rack.url_scheme']
			post = environment['HTTP_HOST']
			if post == nil
				#dumb hack
				post = '127.0.0.1'
			end
			@urlBase = scheme + '://' + post
		end
		
		def processInput
			#remove the UTF8 BOM (possibly requires force_encoding)
			if @rawInput.size > UTF8BOM.size && @rawInput[0..(UTF8BOM.size - 1)] == UTF8BOM
				@rawInput = @rawInput[UTF8BOM.size..-1]
			end
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
end
