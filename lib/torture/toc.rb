
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
    Header = Struct.new(:title, :level, :id, :items, :options)

    def self.Header(title, level, higher_header, **options)
      id = [higher_header[:id], title].compact.join("-").downcase.gsub(/[^\w]/, "-").gsub(/-{2,}/, "-") # TODO: unit-test, asshole!

      Header.new(title, level, id, [], options)
    end
  end
end
