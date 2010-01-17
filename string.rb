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
