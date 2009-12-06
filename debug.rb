def hasDebugPrivilege(request)
	privilegedAddresses = ['127.0.0.1']
	return privilegedAddresses.include? request.address
end
