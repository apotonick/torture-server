module Torture
  module Cms
    module Helper
      module Toc
        # TODO: for the rendering layer, move to user app?
        # Left = Struct.new(:title, :target_url, :items, :versions, :is_expanded) # H1

        # Cell exec_context module
        module Versioned #< Struct.new(:headers, :current)

          # {level_1_headers} is an array of [book_headers, <currently expanded [book,version]>]
          def initialize(level_1_headers:, iterate_context_class: Iterated)
            @book_headers, expanded = level_1_headers
            @expanded_book_name, @expanded_version = expanded

            @iterate_context_class = iterate_context_class
          end


          # TODO: allow this with a simple DSL, where you can add your helpers.
          # TODO: move to cells 5.
          class Iterated
            def initialize(item:, expanded_book_name:, expanded_version:)
              @item = item

              # FIXME: abstract, we're copying over ivars from the collection-host.
              @expanded_book_name = expanded_book_name
              @expanded_version  = expanded_version
            end

            def item
              @item
            end

            def expanded_items#(name, book_h1)
              name, book_h1 = @item

              name == @expanded_book_name ? book_h1.versions_to_h2_headers[@expanded_version].items : []
            end

            def version_folder
              name, book_h1 = @item

              (name == @expanded_book_name && @expanded_version != default_version) ? %(<version>#{@expanded_version}</version>) : ""
            end

            def default_version
              name, book_h1 = @item

              book_h1.default_version
            end

            def default_version_target
              name, book_h1 = @item

              book_h1.versions_to_h2_headers[default_version].options[:target]
            end
          end

          def iterate(items, exec_context_class: @iterate_context_class, **options_for_new, &block)
            items.collect do |item|
              exec_context_class.new(
                item: item,

                expanded_book_name: @expanded_book_name, # FIXME: abstract, we're copying over ivars from the collection-host.
                expanded_version:   @expanded_version,

                **options_for_new

              ).instance_exec(item, &block)
            end
            .join("\n")
          end

        end # Versioned
      end
    end
  end
end
