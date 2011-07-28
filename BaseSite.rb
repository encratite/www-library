require 'www-library/RequestHandler'
require 'www-library/RequestManager'

module WWWLib
  class BaseSite
    attr_reader :mainHandler, :generator, :requestManager

    def initialize(base, generatorClass)
      @base = base
      @requestManager = WWWLib::RequestManager.new
      @mainHandler = WWWLib::RequestHandler.new(base)
      @requestManager.addHandler(@mainHandler)
      @generator = generatorClass.new(self, @requestManager)
      @generator.addStylesheet(getStylesheet(@base))
    end

    def getStaticPath(base, path)
      return @mainHandler.getPath(*(['static', base] + path))
    end

    def getStylesheet(name)
      getStaticPath('style', [name + '.css'])
    end

    def getIcon(name)
      getStaticPath('icon', [name + '.ico'])
    end
  end
end
