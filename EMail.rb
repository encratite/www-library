def isValidEmailAddress address
	localLetter = "[A-Za-z0-9!\#$%&'*+\\-/?^_`{|}~]"
	localString = "#{localLetter}+(\\.#{localLetter}+)*"
	
	firstGroupLetter = '[A-Za-z]'
	groupLetter = '[A-Za-z0-9]'
	group = "#{firstGroupLetter}#{groupLetter}*"
	label = "(xn--)?#{group}(-#{group})*"
	domain = "#{label}(\\.#{label})"
	
	email = "#{localString}@#{domain}"
	patternString = "^#{email}$"
	pattern = Regexp.new patternString

	pattern.match(address) != nil
end

