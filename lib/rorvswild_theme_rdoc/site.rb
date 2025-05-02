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
    end

    class Gem
      attr_reader :name#, :dir

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
    end
  end

  class Project
    attr_reader :name, :docs, :url

    def initialize(repository, tags)
      @repository = repository
      @tags = tags
      @url = @repository.name
      @name = @repository.name.capitalize
      @docs = @tags.map { |tag| Documentation.new(self, tag) }
    end

    def build_docs(dir)
      @docs.each { |doc| doc.build(@repository.checkout(doc.tag), dir) }
    end

    def dir
      @repository.dir
    end
  end

  class Documentation
    attr_reader :tag, :url, :version

    def initialize(project, tag)
      @project = project
      @tag = tag
      @version = self.class.tag_to_version(@tag)
      @url = File.join(project.url, self.class.version_to_path(@version))
    end

    # Normalize tag names since Ruby repository uses v3_4_0, but version numbers are written as 3.4.0.
    def self.tag_to_version(tag)
      version = tag.delete_prefix("v")
      version.gsub!("_", ".")
      version
    end

    # Remove patch number: 1.2.3 -> 1.2
    def self.version_to_path(version)
      return version unless dot1 = version.index(".")
      return version unless dot2 = version.index(".", dot1 + 1)
      version[0...dot2]
    end

    def build(src_dir, doc_dir)
      versionned_dir = File.join(doc_dir, @url)
      title = "#{@project.name} #{@version} Documentation"
      options = ["--root=#{src_dir}", "--include=#{src_dir}/doc", "--title=#{title}", "--main=#{main_file(src_dir)}", "--output=#{versionned_dir}", "--template=rorvswild"]
      RDoc::RDoc.new.document(options)
    end

    def main_file(src_dir)
      ["README.md", "README.rdoc", "README"].find { |file| File.exist?(File.join(src_dir, file)) }
    end
  end

  class Site
    def initialize(urls_and_tags)
      @projects = urls_and_tags.map { |(url, tags)| Project.new(Source.new(url), tags) }
    end

    def build_docs
      @projects.each { |project| project.build_docs("_site") }
    end

    def build_pages
      template = ERB.new(File.read("lib/rorvswild_theme_rdoc/templates/index.html.erb"))
      File.write("_site/index.html", template.result(binding))
      # stylesheets
      theme = File.read("lib/rdoc/generator/template/rorvswild/css/rdoc.css")
      File.write("_site/rdoc.css", theme)
      fonts = File.read("lib/rdoc/generator/template/rorvswild/css/fonts.css")
      File.write("_site/fonts.css", fonts)
      style = File.read("lib/rorvswild_theme_rdoc/templates/style.css")
      File.write("_site/style.css", style)
      # favicons
      favicon = File.read("lib/rorvswild_theme_rdoc/templates/favicon.ico")
      File.write("_site/favicon.ico", favicon)
      apple_touch_icon = File.read("lib/rorvswild_theme_rdoc/templates/apple-touch-icon.png")
      File.write("_site/apple-touch-icon.png", apple_touch_icon)
      icon = File.read("lib/rorvswild_theme_rdoc/templates/icon.svg")
      File.write("_site/icon.svg", icon)
      # og image
      og_image = File.read("lib/rorvswild_theme_rdoc/templates/rubyrubyrubyruby-og.png")
      File.write("_site/rubyrubyrubyruby-og.png", og_image)
    end
  end
end
