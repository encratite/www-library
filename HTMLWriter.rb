require 'set'

module WWWLib
  class SelectOption
    attr_reader :description, :value
    attr_accessor :selected
    def initialize(description, value, selected = false)
      @description = description
      @value = value
      @selected = selected
    end
  end

  class WriterTag
    attr_reader :tag, :newlineType, :isFunction

    #newlineType may be either nil (no newlines), :final (only a newline after the terminating tag) or :full (newlines after every tag)
    def initialize(tag, newlineType = :full, isFunction = true)
      @tag = tag
      @newlineType = newlineType
      @isFunction = isFunction
    end

    def self.inline(tag)
      return WriterTag.new(tag, nil)
    end

    def self.final(tag)
      return WriterTag.new(tag, :final)
    end
  end

  class HTMLWriter
    attr_reader :output

    def initialize(output = nil, request = nil)
      if output == nil
        @output = ''
      else
        @output = output
      end
      @lastCharacter = nil
      @ids = Set.new
      @request = request
    end

    def write(text)
      @output.concat text
      @lastCharacter = text[-1]
      return
    end

    def tagCall(tagString, arguments, newlineType = :full, &function)
      tag(tagString, arguments, function, newlineType)
    end

    def tag(tag, arguments, function = nil, newlineType = :full)
      newline = "\n"

      idSymbol = :id
      id = arguments[idSymbol]
      name = arguments[:name]
      if name != nil && id == nil
        id = getName name
        arguments[idSymbol] = id
      end

      if @ids.include?(id)
        arguments.delete(idSymbol)
      elsif id != nil
        @ids.add id
      end

      newlineTypeSymbol = :newlineType
      newlineTypeOverride = arguments[newlineTypeSymbol]
      if newlineTypeOverride != nil
        newlineType = newlineTypeOverride
        arguments.delete(newlineTypeSymbol)
      end

      argumentString = ''
      arguments.each { |key, value| argumentString += " #{key.to_s}=\"#{value}\"" }
      if function == nil
        write "<#{tag}#{argumentString} />"
      else
        write "<#{tag}#{argumentString}>"
        write newline if newlineType == :full
        data = function.call
        case data
        when String
          write data
        when Fixnum
          write data.to_s
        when Array
          #common sight in .each calls at the end of the tag block
          #let's just ignore these instead of raising an exception
        when nil
        else
          raise "Invalid class returned by tag block: #{data.class}"
        end
        write newline if newlineType == :full && @lastCharacter != "\n"
        write "</#{tag}>"
      end
      write newline if newlineType != nil
      return
    end

    def self.createMethods(methods)
      methods.each do |method|
        if method.class != WriterTag
          method = WriterTag.new(method)
        end
        if method.isFunction
          define_method(method.tag) do |arguments = {}, &block|
            tag(method.tag, arguments, block, method.newlineType)
          end
        else
          define_method(method.tag) do |arguments = {}|
            tag(method.tag, arguments, nil, method.newlineType)
          end
        end
      end
    end

    def getName(label)
      label.scan(/[A-Za-z0-9]/).join('')
    end

    def form(action, arguments = {}, &block)
      arguments[:method] = 'post'
      arguments[:action] = action
      tag('form', arguments, block)
      return
    end

    def withLabel(label, &block)
      ul class: 'formLabel' do
          li { label + ':' }
          li { block.call }
        end
           return
         end

      def field(type, label, name, value, arguments)
        arguments[:type] = type
        arguments[:name] = name
        arguments[:value] = value

        withLabel(label) do tag('input', arguments) end

        return
      end

      def text(label, name, value = nil, arguments = {})
        field('text', label, name, value, arguments)
        return
      end

      def password(label, name, value = nil, arguments = {})
        field('password', label, name, value, arguments)
        return
      end

      def hidden(name, value = nil, arguments = {})
        arguments[:type] = 'hidden'
        arguments[:name] = name
        arguments[:value] = value

        tag('input', arguments)

        return
      end

      def radio(label, name, value, checked = false, arguments = {})
        arguments[:type] = 'radio'
        arguments[:name] = name
        arguments[:value] = value
        arguments[:checked] = 'checked' if checked
        arguments[:class] = 'radio' if arguments[:class] == nil

        tag('input', arguments, nil, nil)
        write " #{label}\n"

        return
      end

      def select(name, options, arguments = {})
        function = lambda do
          gotASelection = false
          options.each do |option|
            currentArguments = {value: option.value}
            if option.selected
              raise 'You cannot specify more than one selected element in a <select> tag.' if gotASelection
              gotASelection = true
              currentArguments[:selected] = 'selected'
            end
            option currentArguments do option.description end
          end
        end
        arguments[:name] = name
        tagFunction = lambda { tag('select', arguments, function) }
        label = arguments[:label]
        if label == nil
          tagFunction.call
        else
          arguments.delete :label
          withLabel label do tagFunction.call end
        end
        return
      end

      def textArea(label, name, value = '', arguments = {})
        function = lambda { value }
        arguments[:name] = name
        withLabel label do tag('textarea', arguments, function) end
        return
      end

      def submit(description = 'Submit', arguments = {})
        arguments = {type: 'submit', value: description, class: 'submit'}

          function = lambda { tag('input', arguments, nil, :final) }

          needSpan = false
          if @request != nil
            agent = @request.agent
            needSpan = agent == :ie6 || agent == :ie7
          end

          p do
            if needSpan
              span do
                function.call
              end
            else
              function.call
            end
          end

          return
        end

        def input(arguments = {})
          tag('input', arguments, nil, true, :final)
          return
        end

        def col(arguments = {})
          tag('col', arguments)
          return
        end

        def cdata(&block)
          write "/*<![CDATA[*/\n"
          write block.call
          write "/*]]>*/\n"
          return
        end

        self.createMethods [
                            WriterTag.inline('a'),
                            WriterTag.inline('b'),
                            'body',
                            'colgroup',
                            'div',
                            'head',
                            'html',
                            WriterTag.inline('i'),
                            WriterTag.final('li'),
                            WriterTag.new('link', :final, false),
                            'meta',
                            WriterTag.final('option'),
                            WriterTag.final('p'),
                            'script',
                            WriterTag.inline('span'),
                            'style',
                            'table',
                            WriterTag.final('title'),
                            'td',
                            'th',
                            'tr',
                            'ul',
                           ]
      end
    end
