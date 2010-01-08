require 'site/HTML'

class SymbolTransfer
	def getMemberSymbol(symbol)
		return ('@' + symbol.to_s).to_sym
	end

	def translateSymbolName(name)
		output = ''
		isUpper = false
		name.to_s.each do |char|
			if char == '_'
				isUpper = true
				next
			end
			
			if isUpper
				char = char.upcase
				isUpper = false
			end
			
			output += char
		end
	end

	def transferSymbols(input, hash = {})
		input.each do |symbol, value|
			translatedSymbol = hash[symbol]
			
			translatedSymbol = translateSymbolName(symbol) if translatedSymbol == nil
			
			memberSymbol = getMemberSymbol translatedSymbol
			if value.class == String
				value = HTMLEntities::encode value
			end
			instance_variable_set(memberSymbol, value)
			
			send(:define_method, translatedSymbol) do
				return instance_variable_get(memberSymbol)
			end
			
			operatorSymbol = (translatedSymbol.to_s + '=').to_sym
			send(:define_method, operatorSymbol) do |value|
				instance_variable_set(memberSymbol, value)
			end
		end
	end
end
