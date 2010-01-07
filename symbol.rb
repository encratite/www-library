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

def transferSymbols(object, input, hash = {})
	input.each do |symbol, value|
		translatedSymbol = hash[symbol]
		
		translatedSymbol = translateSymbolName(symbol) if translatedSymbol == nil
		
		memberSymbol = getMemberSymbol translatedSymbol
		object.instance_variable_set(memberSymbol, value)
		
		object.send(:define_method, translatedSymbol) do
			return instance_variable_get(memberSymbol)
		end
		
		operatorSymbol = (translatedSymbol.to_s + '=').to_sym
		object.send(:define_method, operatorSymbol) do |value|
			instance_variable_set(memberSymbol, value)
		end
	end
end
