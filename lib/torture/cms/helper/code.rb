module Torture
  module Cms
    # Helpers are for cells!
    module Helper
      module Code
        def code(*args, **kws)
          dont_extract = @options[:extract] === false
          code = ""

          if block_given? # TODO: test me!!!
            dont_extract = true
            code = yield.chomp
          end

          code = dont_extract ? code : extract(*args, **kws)
          Kramdown::Document.new("\n\t#{code.gsub("\n", "\n\t")}").to_html
        end

        # def extract(section, root:, file:, collapse: nil, unindent: true)
        private def extract(section, **options)
          options = @options.merge(collapse: nil, unindent: true, **options)

          puts "@@@@@ #{options.inspect}"

          extract_from(**options)
        end

        private def extract_from(root:, file:, section:, collapse:, unindent:, sub:, **)
          # Torture::Snippet from the {torture} gem.
          Torture::Snippet.extract_from(file: File.join(root, file), marker: section, collapse: collapse, unindent: unindent, sub: sub)
        end
      end
    end
  end
end
