def hasDebugPrivilege(request)
	privilegedAddresses = ['127.0.0.1']
	#puts "#{privilegedAddresses} vs. #{request.address}"
	return privilegedAddresses.include? request.address
end
