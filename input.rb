module WWWLib
	def self.readId(argument)
		return nil if /0|[1-9][0-9]*/.match(argument) == nil
		return Integer(argument)
	end
end
