module WWWLib
  class RandomString
    def self.createArray
      output = []
      targets =
        [
         ['A', 'Z'],
         ['a', 'z'],
         ['0', '9']
        ]

      targets.each { |first, last| output.concat (first..last).to_a }

      output
    end

    def self.get(length)
      output = ''
      length.times { output.concat(SessionCharacters[rand SessionCharacters.size]) }
      output
    end

    SessionCharacters = createArray
  end
end
