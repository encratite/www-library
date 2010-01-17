def extractString(input, left, right)
	offset1 = input.index(left)
	return nil if offset1 == nil
	offset2 = input.index(right, offset1 + left.size)
	return nil if offset2 == nil
	output = input[offset1..offset2]
	return output
end
