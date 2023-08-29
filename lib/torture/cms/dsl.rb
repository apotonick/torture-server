module Torture
  module Cms
    module DSL
      # Transform public configuration structure to something better to work with internally.
      def self.call(pages)
        pages.collect do |book, options|
          versions      = options.find_all { |k, v| k.is_a?(String) }.to_h
          book_options  = options.slice(*(options.keys - versions.keys))

          versions = versions.collect do |version, options|
            sections         = options.find_all { |k, v| k.is_a?(String) }.to_h
            version_options  = options.slice(*(options.keys - sections.keys))

            [
              version,
              {sections: sections, options: version_options}
            ]
          end.to_h


          [
            book,
            versions
          ]
        end.to_h
      end
    end
  end
end
