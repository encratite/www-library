module WWWLib
	def extractString(input, left, right)
		offset1 = input.index(left)
		return nil if offset1 == nil
		offset1 += left.size
		offset2 = input.index(right, offset1)
		return nil if offset2 == nil
		offset2 -= 1
		output = input[offset1..offset2]
		return output
	end

	def slashify(input)
		separator = '/'
		return separator + input.join(separator)
	end

	def getSizeString(size)
		fullBytesStringMode = false
		
		sizeStrings =
		[
			'B',
			'KiB',
			'MiB',
			'GiB'
		]
		
		factor = 1024.0
		
		offset = 0
		while offset < sizeStrings.size && size >= factor
			size /= factor
			offset += 1
		end
		
		unit = sizeStrings[offset]
		
		if offset == 0
			unit = 'byte' if fullBytesStringMode
			output = "#{size} #{unit}"
			output += 's' if size > 1 && fullBytesStringMode
			return output
		else
			return sprintf('%.1f %s', size, unit)
		end
	end
end
