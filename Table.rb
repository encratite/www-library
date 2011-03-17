module WWWLib
  class Table
    def initialize(output, tableClass = nil, id = nil)
      @output = output
      targets =
        [
         [tableClass, 'class'],
         [id, 'id']
        ]
      additionalString = ''
      targets.each { |variable, name| additionalString += " #{name}=\"#{variable}\"" if variable != nil }
      append "<table#{additionalString}>\n"
    end

    def finalise
      append "</table>\n"
    end

    def append(text)
      @output.concat text
    end

    def row
      append "<tr>\n"
    end

    def endOfRow
      append "</tr>\n"
    end

    def column(content)
      append "<td>#{content}</td>\n"
    end
  end
end
