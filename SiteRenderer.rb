require 'www-library/ScriptEntry'
require 'www-library/HTMLWriter'

module WWWLib
  class SiteRenderer
    Doctype = '<!doctype html>'
    HTMLType = 'text/html'
    CSSType = 'text/css'
    IconType = 'image/ico'
    Charset = 'utf-8'

    def initialize
      @stylesheets = []
      @scripts = []
      @inlineStylesheets = []
      @metas = {}
      @icon = nil
    end

    def addStylesheet(stylesheet)
      @stylesheets << stylesheet
    end

    def addScript(source, type = 'text/javascript')
      @scripts << ScriptEntry.new(type, source)
    end

    def addInlineStylesheet(code)
      @inlineStylesheets << code
    end

    def setIcon(icon)
      @icon = icon
    end

    def setMeta(name, content)
      @metas[name] = content
    end

    def get(title, content, additionalHead = nil)
      output = "#{Doctype}\n"
      writer = HTMLWriter.new(output)
      writer.html do
        writer.head do
          writer.meta('charset' => Charset)

          if @icon != nil
            writer.link(rel: 'icon', type: IconType, href: @icon)
          end

          @stylesheets.each do |stylesheet|
            writer.link(rel: 'stylesheet', type: CSSType, media: 'screen', href: stylesheet)
          end

          @metas.each do |name, content|
            writer.meta('name' => name, 'content' => content)
          end

          @inlineStylesheets.each do |stylesheet|
            writer.style(type: CSSType, media: 'screen') do
              writer.cdata { stylesheet }
            end
          end

          @scripts.each do |script|
            writer.script(type: script.type, src: script.source, newlineType: :final) { '' }
          end

          writer.title { title }

          if additionalHead != nil
            writer.write(additionalHead)
          end
        end
        writer.body do
          content
        end
      end
      return writer.output
    end
  end
end
