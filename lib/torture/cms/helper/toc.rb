module Torture
  module Cms
    module Helper
      module Toc
        # TODO: for the rendering layer, move to user app?
        # Left = Struct.new(:title, :target_url, :items, :versions, :is_expanded) # H1

        class Versioned #< Struct.new(:headers, :current)

          # def initialize(headers)
          #   @headers = headers.collect do |title, versions|
          #     H1.new(title, versions)
          #   end
          # end

          # def each(&block)
          #   @headers.each(&block)
          # end

          # TODO: 2BRM
          def self.collapsable(headers, expanded:)
            return [headers, expanded]

          end
        end # Versioned
      end
    end
  end
end
