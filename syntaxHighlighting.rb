require 'fileutils'

require 'nil/file'

require 'www-library/string'

module WWWLib
  def self.syntaxHighlighting(script, input, installationSourcePath = nil)
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
    #scriptFile = 'pastebin.vim'
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
end
