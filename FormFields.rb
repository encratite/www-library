require 'nil/symbol'

module WWWLib
  class FormFields
    attr_reader :error, :missingSymbol

    include SymbolicAssignment

    def initialize(request)
      @error = false
      self.class.constants.each do |symbol|
        name = self.class.const_get(symbol)
        value = request.getPost(name)
        if value == nil
          @error = true
          @missingSymbol = symbol
          return true
        end
        symbolString = symbol.to_s
        translatedSymbol = symbolString[0].downcase + symbolString[1..-1]
        setPublicMember(translatedSymbol, value)
      end
    end
  end
end
