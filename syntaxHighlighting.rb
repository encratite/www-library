require 'fileutils'
require 'tempfile'

require 'nil/file'

require 'www-library/string'
require 'www-library/HTML'
require 'www-library/HTMLWriter'

module WWWLib
  def self.getSyntaxHighlightedMarkup(script, input, installationSourcePath = nil)
    outputFile = Tempfile.new('outputFile')
    outputFile.close

    input = input.delete("\r")
    inputFile = Tempfile.new('inputFile')
    inputFile << input
    inputFile.close

    flags = [
      'f', #Foreground - do not disconnect from the program that started vim
      'n', #No swap file, use memory only
      'X', #Do not connect to the X server to get the window title, do not use X clipboard functionality
      'e', #Ex mode (like "ex")
      's', #Silent (batch) mode (only for "ex")
    ]

    scriptFile = 'html-highlighting.vim'
    scriptPath = Nil.joinPaths('syntax', scriptFile)

    if installationSourcePath != nil
      vimDirectory = Nil.joinPaths(Dir.home, '.vim')
      localPath = Nil.joinPaths(installationSourcePath, scriptFile)
      fullPath = Nil.joinPaths(vimDirectory, scriptPath)
      FileUtils.mkdir_p(File.dirname(fullPath))
      #FileUtils.cp(localPath, fullPath)
    end

    vimCommands =
      [
       "set filetype=#{script}",
       'set background=light',
       'set wrap linebreak textwidth=0',
       'syntax on',
       'let html_use_css=1',
       "runtime #{scriptPath}",
       "wq! #{outputFile.path}",
       'quit',
      ]

    flags = flags.map { |flag| "-#{flag}" }
    flags = flags.join ' '

    vimCommands = vimCommands.map { |cFlag| "-c \"#{cFlag}\"" }
    vimCommands = vimCommands.join ' '

    line = "vim #{flags} #{vimCommands} \"#{inputFile.path}\""
    output = `#{line}`
    markup = outputFile.open.read
    code = WWWLib.extractString(markup, "<pre>\n", "</pre>")
    return code
  end

  def self.getCodeList(writer, content)
    contentLines = content.split "\n"
    writer.ul(class: 'lineNumbers') do
      lineCounter = 1
      contentLines.size.times do |i|
        arguments = {}
        arguments[:class] = 'lastLine' if lineCounter == contentLines.size
        writer.li(arguments) { lineCounter.to_s }
        lineCounter += 1
      end
      nil
    end

    isEven = false
    writer.ul(class: 'contentList') do
      lineCounter = 1
      contentLines.each do |line|
        if lineCounter == contentLines.size
          lineClass = isEven ? 'evenLastLine' : 'oddLastLine'
        else
          lineClass = isEven ? 'evenLine' : 'oddLine'
        end
        writer.li(class: lineClass) { line }
        isEven = !isEven
        lineCounter += 1
      end
    end

    nil
  end

  def self.getHighlightedList(script, input)
    if script == nil
      markup = WWWLib::HTMLEntities.encode(input)
    else
      markup = WWWLib.getSyntaxHighlightedMarkup(script, input)
    end
    writer = HTMLWriter.new
    WWWLib.getCodeList(writer, markup)
    return writer.output
  end
end
