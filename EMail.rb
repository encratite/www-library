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


[
	'wef@wefwef.net',
	'wef.wef$wef@wefwef.net',
	'wef@xn--wefwef.xn--net',
	'.wef@wefwef.net',
	'we..f@wefwef.net',
	'domain.net',
	'-invalid.domain.net',
	'valid-domain.net',
	'xn--valid.xn--net',
	'0invalid-domain.net',
	'group1',
	'1nogroup',
	'val1d.local',
	'invalid..local',
	'invalid.local.',
	'.invalid.local',
	'1',
	'~',
	'.'
].each { |address| puts "#{address}: #{isValidEmailAddress(address)}" }
