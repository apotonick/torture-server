module Torture
  module Cms
    module Helper
      module Toc
        # H1 = Struct.new(:title, :items) # H1
        class Versioned #< Struct.new(:headers, :current)

          # def initialize(headers)
          #   @headers = headers.collect do |title, versions|
          #     H1.new(title, versions)
          #   end
          # end

          # def each(&block)
          #   @headers.each(&block)
          # end

          def self.collapsable(headers, expanded:)
            headers.collect do |title, versions|
              expanded_version = versions.keys.first # FIXME: make this dynamic, obviously.

              h1 = versions[expanded_version].first # FIXME: why is that an array?

              if title == expanded
                h1
              else

                Torture::Toc::Header.new(h1.title, h1.level, h1.id, [], h1.options)
              end
            end
          end
        end # Versioned
      end
    end
  end
end
