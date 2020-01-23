
module Torture
  def self.merge_toc(a, b)
    Hash[
      b.collect do |k, ary|
        ary += a[k] || []
        [k, ary]
      end
    ]
  end

  module Toc
    Header = Struct.new(:title, :level, :id, :items)

    def self.Header(level, title, permalink, higher_header)
      id = [higher_header[:id], permalink].compact.join("-").downcase.gsub(/[^\w]/, "-").gsub(/-{2,}/, "-") # TODO: unit-test, asshole!

      Header.new(title, level, id, [])
    end
  end
end
