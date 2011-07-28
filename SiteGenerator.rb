require 'www-library/HTMLWriter'
require 'www-library/SiteRenderer'

module WWWLib
  class SiteGenerator < SiteRenderer
    extend GetWriter

    def initialize(requestManager)
      super()
      @requestManager = requestManager
    end
  end
end
