module WWWLib
	class PrivilegedAddressContainer
		def initialize
			@addresses = ['127.0.0.1']
		end
		
		def add(address)
			@addresses << address
		end
		
		def isPrivileged(address)
			return @addresses.include?(address)
		end
	end
	
	PrivilegedAddresses = PrivilegedAddressContainer.new
	
	def self.hasDebugPrivilege(request)
		return PrivilegedAddresses.isPrivileged(request.address)
	end
end
