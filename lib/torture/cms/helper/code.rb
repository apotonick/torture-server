module Torture
  module Cms
    # Helpers are for cells!
    module Helper
      module Code
        def code(*args, code_tag_attributes: nil, **kws)
          dont_extract = @options[:extract] === false
          code = ""

          if block_given? # TODO: test me!!!
            dont_extract = true
            code = yield.chomp
          end

          code = dont_extract ? code : extract(*args, **kws)
          # Kramdown::Document.new("\n\t#{code.gsub("\n", "\n\t")}").to_html

          escaped_code = code.gsub("<", "&lt;").gsub(">", "&gt;") # this is sometimes not done properly in the "final" Kramdown run on section level.

          %(<pre #{html_attributes(@options[:pre_attributes])}><code #{html_attributes(code_tag_attributes, @options[:code_attributes])}>#{escaped_code}</code></pre>)
        end

        # def extract(section, root:, file:, collapse: nil, unindent: true)
        private def extract(section, **options)
          options = @options.merge(collapse: nil, unindent: true, section: section, **options)

          # puts "@@@@@ #{options.inspect}"

          extract_from(**options)
        end

        private def extract_from(root:, file:, section: nil, collapse:, unindent:, sub: nil, **) # FIXME: when using {code ruby do...end} all those options don't make sense.
          # Torture::Snippet from the {torture} gem.
          Torture::Snippet.extract_from(file: File.join(root, file), marker: section, collapse: collapse, unindent: unindent, sub: sub)
        end

        private def html_attributes(user_options, options=nil)
          options = user_options || options
          return if options.nil?

          options.collect { |k,v| %(#{k}="#{v}") }.join(" ")
        end
      end
    end
  end
end
