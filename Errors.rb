require 'www-library/MIMEType'
require 'www-library/RequestManager'

module WWWLib
  module Errors
    def plainError(message)
      raise WWWLib::RequestManager::Exception.new([WWWLib::MIMEType::Plain, message])
    end

    def argumentError
      plainError 'Invalid argument.'
    end
  end
end
