require 'www-library/SiteRenderer'

module WWWLib
  class SiteGenerator < SiteRenderer
    def initialize(requestManager)
      super()
      @requestManager = requestManager
    end
  end
end
