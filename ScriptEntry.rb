module WWWLib
  class ScriptEntry
    attr_reader :type, :source
    def initialize(type, source)
      @type = type
      @source = source
    end
  end
end
