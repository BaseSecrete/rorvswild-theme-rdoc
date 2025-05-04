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
        @name = File.basename(@url = url, File.extname(@url))
        @dir = "source/git/#{name}"
      end

      def clone_quickly
        return if File.exist?(@dir)
        FileUtils.mkpath(parent_dir = File.dirname(@dir))
        system("git -C #{parent_dir} clone --filter=tree:0 #{@url}")
      end

      def checkout(tag)
        clone_quickly
        system("git -C #{@dir} checkout #{tag}")
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
        `curl -s #{@info["gem_uri"]} | tar -x --to-stdout --wildcards 'data.tar.gz' | tar -xz -C #{dir}`
        dir
      end

      def versions
        Gems.versions(name).map { |v| Version.new(v["number"]) }
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
    attr_reader :docs, :url

    def initialize(source, min_version)
      @url = (@source = source).name
      @min_version = min_version
      @versions = Version.latest_minors_since(@source.versions, min_version)
      @docs = @versions.map { |version| Documentation.new(self, version) }
    end

    def build_docs(dir)
      @docs.each { |doc| doc.build(@source.checkout(doc.version.tag), dir) }
    end

    def dir
      @source.dir
    end

    def summary
      if @source.is_a?(RorVsWildThemeRdoc::Source::Gem)
        @source.instance_variable_get(:@info)["info"]
      else
        repo_name = @source.instance_variable_get(:@url).split('/').last(2).join('/').gsub('.git', '')
        `curl -s https://api.github.com/repos/#{repo_name} | grep '"description":' | cut -d'"' -f4`.strip
      end
    end
  end

  class Documentation
    attr_reader :url, :version

    def initialize(project, version)
      @project, @version = project, version
      @url = File.join(project.url, @version.short_number)
    end

    def build(src_dir, doc_dir)
      versionned_dir = File.join(doc_dir, @url)
      title = "#{@project.url} #{@version.number} documentation"
      options = ["--root=#{src_dir}", "--include=#{src_dir}/doc", "--title=#{title}", "--main=#{main_file(src_dir)}", "--output=#{versionned_dir}", "--template=rorvswild"]
      RDoc::RDoc.new.document(options)
    end

    def main_file(src_dir)
      ["README.md", "README.rdoc", "README"].find { |file| File.exist?(File.join(src_dir, file)) }
    end
  end

  class Site
    def initialize(url_and_min_version)
      @projects = url_and_min_version.map { |(url, min_version)| Project.new(Source.new(url), Version.new(min_version)) }
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
