require 'www-library/RequestManager'

module WWWLibrary
  class SiteContainer
    attr_reader :title

    def initialize(site)
      @site = site
      @generator = site.generator
      installHandlers
    end

    def addHandler(handler)
      @site.mainHandler.add(handler)
    end

    def raiseError(error, request)
      raise RequestManager::Exception.new(@generator.get(error, request))
    end
  end
end
