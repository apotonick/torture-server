module Torture
  module Cms
    module DSL
      # Transform public configuration structure to something better to work with internally.
      def self.call(pages)
        top_level_options, pages = normalize_top_level_options(pages)

        pages.collect do |book, options|
          versions      = options.find_all { |k, v| k.is_a?(String) }.to_h
          book_options  = options.slice(*(options.keys - versions.keys))

          versions = versions.collect do |version, options|
            sections         = options.find_all { |k, v| k.is_a?(String) }.to_h
            version_options  = options.slice(*(options.keys - sections.keys))

            version_options = top_level_options.merge(version_options)

            [
              version,
              {sections: sections, options: version_options}
            ]
          end.to_h


          [
            book,
            {
              **book_options,
              versions: versions,
            }
          ]
        end.to_h
      end

      def self.normalize_top_level_options(mixed_options)
        pages = mixed_options.find_all { |k, v| k.is_a?(String) }.to_h
        options = mixed_options.slice(*(mixed_options.keys - pages.keys)) # FIXME: abstract.

        return options, pages
      end
    end
  end
end
