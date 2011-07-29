module WWWLib
  class FormFields
    attr_reader :error

    def initialize(request)
      @error = false
      self.constants.each do |symbol|
        name = self.const_get(symbol)
        value = request.getPost(symbol)
        if value == nil
          @error = true
          return true
        end
        
      end
    end
  end
end
