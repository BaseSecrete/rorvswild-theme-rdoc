require "bundler/gem_tasks"

require "rdoc"
require "rorvswild_theme_rdoc"

namespace :site do
  namespace :build do
    desc "Build docs for Ruby and gems"
    task :docs do
      site.build_docs
    end

    desc "Build site pages (index.html)"
    task :pages do
      require "erb"
      site.build_pages
    end
  end

  desc "Build docs and pages"
  task build: ["site:build:docs", "site:build:pages"]

  def site
    @site ||= RorVsWildThemeRdoc::Site.new(
      "https://github.com/ruby/ruby.git" => %w[v3_2_0 v3_3_0 v3_4_0].reverse,
      "https://github.com/rails/rails.git" => %w[v7.1.0 v7.2.0 v8.0.0].reverse,
      "https://github.com/ruby/rdoc.git" => %w[v6.13.1 v6.11.1 v6.10.0].reverse,
    )
  end
end

module RorVsWildThemeRdoc
  class Repository
    attr_reader :name, :dir

    def initialize(url)
      @url = url
      @name = File.basename(@url, File.extname(@url))
      @dir = "repositories/#{name}"
    end

    def clone_quickly
      parent_dir = File.dirname(dir)
      Dir.exist?(parent_dir) or Dir.mkdir(parent_dir)
      system("git -C #{parent_dir} clone --filter=tree:0 #{@url}") if !File.exist?(@dir)
    end

    def checkout(tag)
      system("git -C #{@dir} checkout #{tag}")
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
      @repository.clone_quickly
      for doc in @docs
        @repository.checkout(doc.tag)
        doc.build(dir)
      end
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

    def build(dir)
      versionned_dir = File.join(dir, @url)
      title = "#{@project.name} #{@version} Documentation"
      options = ["--root=#{@project.dir}", "--include=#{@project.dir}/doc", "--title=#{title}", "--main=#{main_file}", "--output=#{versionned_dir}", "--template=rorvswild"]
      RDoc::RDoc.new.document(options)
    end

    def main_file
      ["README.md", "README.rdoc", "README"].find { |file| File.exist?(File.join(@project.dir, file)) }
    end
  end

  class Site
    def initialize(urls_and_tags)
      @projects = urls_and_tags.map { |(url, tags)| Project.new(Repository.new(url), tags) }
    end

    def build_docs
      @projects.each { |project| project.build_docs("_site") }
    end

    def build_pages
      template = ERB.new(File.read("lib/rorvswild_theme_rdoc/templates/index.html.erb"))
      File.write("_site/index.html", template.result(binding))
    end
  end
end
