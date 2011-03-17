module WWWLib
  class MenuEntry
    attr_accessor :path
    attr_reader :description, :condition

    def initialize(path, description, condition)
      if path.class == Array
        @path = path
      else
        @path = [path]
      end
      @description = description
      @condition = condition
    end
  end
end
