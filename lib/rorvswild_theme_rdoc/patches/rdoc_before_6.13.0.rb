if Gem::Version.new(RDoc::VERSION) < Gem::Version.new("6.13.0")
  # https://github.com/ruby/rdoc/pull/1315
  module RDoc
    class NormalClass
      attr_reader :includes
      attr_reader :extends
      attr_reader :constants
    end
  end
end
