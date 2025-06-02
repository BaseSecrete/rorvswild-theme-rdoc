# frozen_string_literal: true

require "gems"
require "rdoc"
require "erb"

module RorVsWildThemeRdoc
  class Source
    def self.new(*args)
      instance = File.extname(args[0]) == ".git" ? Git.allocate : Gem.allocate
      instance.send(:initialize, *args)
      instance
    end

    class Git
      attr_reader :name, :dir

      def initialize(url)
        @owner, @name = (@url = url).split("/")[-2..-1]
        @name = File.basename(@name, File.extname(@name))
        @info = JSON.parse(Net::HTTP.get(URI("https://api.github.com/repos/#{@owner}/#{@name}")))
        @dir = "source/git/#{name}"
      end

      def clone_quickly
        return if File.exist?(@dir)
        FileUtils.mkpath(parent_dir = File.dirname(@dir))
        system("git -C #{parent_dir} clone --filter=tree:0 --quiet #{@url}")
      end

      def checkout(tag)
        clone_quickly
        system("git -C #{@dir} checkout --quiet #{tag}")
        @dir
      end

      def versions
        clone_quickly
        result = []
        `git -C #{@dir} tag`.split.each do |tag|
          if ::Gem::Version.correct?(number = Version.tag_to_number(tag))
            result << Version.new(tag)
          end
        end
        result
      end

      def description
        @info["description"]
      end
    end

    class Gem
      attr_reader :name

      def initialize(name)
        @info = Gems.info(@name = name)
        @versions = Gems.versions(name)
        @url = name
      end

      def checkout(version)
        versioned_named = "#{name}-#{version}"
        FileUtils.mkpath(dir = "source/gem/#{versioned_named}")
        `curl -s #{@info["gem_uri"]} | tar -x --to-stdout data.tar.gz | tar -xz -C #{dir}`
        dir
      end

      def versions
        Gems.versions(name).map { |v| Version.new(v["number"]) }
      end

      def description
        @info["info"]
      end
    end
  end

  class Version
    include Comparable

    attr_reader :tag, :number, :short_number, :gem_version

    # Normalize tag names since Ruby repository uses v3_4_0, but version numbers are written as 3.4.0.
    def self.tag_to_number(tag)
      version = tag.gsub(/^[^\d]*/, "")
      version.tr!("_", ".")
      version
    end

    # Remove patch number: 1.2.3 -> 1.2
    def self.shorten_number(version)
      return version unless dot1 = version.index(".")
      return version unless dot2 = version.index(".", dot1 + 1)
      version[0...dot2]
    end

    def self.latest_minors_since(versions, min_version)
      versions.select { |v| min_version <= v }
        .group_by { |v| v.short_number }
        .map { |_, minors| minors.max }
        .sort!
    end

    def initialize(tag)
      @number = self.class.tag_to_number(@tag = tag)
      @short_number = self.class.shorten_number(@number)
      @gem_version = Gem::Version.new(number)
    end

    def <=>(other)
      @gem_version <=> other.gem_version
    end
  end

  class Project
    attr_reader :docs, :url, :fitter, :options

    def initialize(source, min_version, fitter, options)
      @url = (@source = source).name
      @min_version = min_version
      @fitter = fitter
      @versions = Version.latest_minors_since(@source.versions, min_version)
      @docs = @versions.map { |version| Documentation.new(self, version) }
      @options = options
    end

    def build_docs(dir)
      @docs.each { |doc| doc.build(@source.checkout(doc.version.tag), dir) }
    end

    def dir
      @source.dir
    end

    def summary
      @source.description
    end
  end

  class Documentation
    attr_reader :url, :version

    DEFAULT_INDEXES = ["doc/index.md", "README.md", "readme.md", "README.rdoc", "readme.rdoc", "README", "readme"]

    def initialize(project, version)
      @project, @version = project, version
      @url = File.join(project.url, @version.short_number)
    end

    def build(src_dir, doc_dir)
      dst_dir = File.join(doc_dir, @url)
      args = [
        "--root", src_dir,
        "--template", "rorvswild",
        "--main", index_file(src_dir),
        "--op", dst_dir,
        "--title", "#{@project.url} #{@version.number} documentation",
        "--exclude", "Gemfile",
        "--exclude", "Gemfile.lock",
        "--exclude", "Rakefile",
        "--exclude", "\.(css|js|json|lock|rake|rbs|sh|sig|sqlite3|toml|tt|yaml)$",
        "--quiet",
        src_dir
      ]
      RDoc::RDoc.new.document(args)
      @project.fitter&.adjust(src_dir, dst_dir)
    end

    def index_file(src_dir)
      (@project.options && @project.options[:index]) ||
        DEFAULT_INDEXES.find { |file| File.exist?(File.join(src_dir, file)) }
    end
  end

  class Fitter
    def initialize(options)
      @options = options
    end

    def adjust(src_dir, doc_dir)
      for path in @options[:copy]
        next if !File.exist?(src_path = File.join(src_dir, path))
        FileUtils.mkpath(File.dirname(dst_path = File.join(doc_dir, path)))
        `cp -R #{src_path} #{dst_path}`
       end
    end
  end

  class Site
    def initialize(data)
      @projects = data.map { |params|
        min_version = Version.new(params[:min_version])
        fitter = params[:fitter] ? Fitter.new(params[:fitter]) : nil
        Project.new(Source.new(params[:source]), min_version, fitter, params[:options])
      }
    end

    def build_docs
      @projects.each { |project| project.build_docs("_site") }
    end

    def build_pages
      FileUtils.mkpath("_site")
      template = ERB.new(File.read("lib/rorvswild_theme_rdoc/site/index.html.erb"))
      File.write("_site/index.html", template.result(binding))
      `cp -R lib/rdoc/generator/template/rorvswild/css/* _site`
      `cp lib/rorvswild_theme_rdoc/site/* _site`
    end
  end
end
