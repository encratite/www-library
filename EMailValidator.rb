module WWWLib
  class EMailValidator
    def self.createPattern
      localLetter = "[A-Za-z0-9!\#$%&'*+\\-/?^_`{|}~]"
      localString = "#{localLetter}+(\\.#{localLetter}+)*"

      firstGroupLetter = '[A-Za-z]'
      groupLetter = '[A-Za-z0-9]'
      group = "#{firstGroupLetter}#{groupLetter}*"
      label = "#{group}(-+#{group})*"
      domain = "#{label}(\\.#{label})*"

      email = "#{localString}@#{domain}"
      patternString = "\A#{email}\z"
      Regexp.new patternString
    end

    def self.isValidEmailAddress address
      return Pattern.match(address) != nil
    end

    Pattern = self.createPattern
  end
end
