require 'www-library/MIMEType'
require 'www-library/RequestManager'

module WWWLibrary
  def plainError(message)
    raise WWWLib::RequestManager::Exception.new([WWWLib::MIMEType::Plain, message])
  end

  def argumentError
    plainError 'Invalid argument.'
  end
end
