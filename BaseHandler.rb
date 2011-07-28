require 'www-library/Errors'
require 'www-library/HTMLWriter'
require 'www-library/RequestManager'

module WWWLib
  class BaseHandler
    include GetWriter
    include Errors

    def initialize(site)
      @site = site
      @generator = site.generator
      installHandlers
    end

    def addHandler(handler)
      @site.mainHandler.add(handler)
    end

    def raiseError(error, request)
      raise WWWLib::RequestManager::Exception.new(@generator.get(error, request))
    end
  end
end
