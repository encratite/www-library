require 'htmlentities'

module WWWLib
  class HTMLEntities
    HtmlCoder = ::HTMLEntities.new

    def self.encode(input)
      return HtmlCoder.encode(input)
    end

    def self.decode(input)
      return HtmlCoder.decode(input)
    end
  end
end
