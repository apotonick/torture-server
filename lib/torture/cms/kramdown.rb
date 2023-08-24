  require "kramdown"

  module Kramdown::Parser
    # TODO: naming, this is specific to Tailwind.
    class Torture < Kramdown::Parser::Kramdown
      def new_block_el(*args)
        type, value, attr, rest = args

        if type == :p
          options = {class: "mt-6"}
          return super(type, value, options, rest)
        end

        super
      end
    end
  end
