require "bundler/gem_tasks"

require "rdoc"
require "rorvswild_theme_rdoc"

namespace :site do
  task :build do
    RorVsWildThemeRdoc::Site.build(
      "https://github.com/ruby/ruby.git" => %w[v3_2_0 v3_3_0 v3_4_0] ,
      "https://github.com/ruby/rdoc.git" => %w[v6.13.1 v6.11.1 v6.10.0],
      "https://github.com/rails/rails.git" => %w[v7.1.0 v7.2.0 v8.0.0],
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
    attr_reader :name

    def initialize(repository, tags)
      @repository = repository
      @tags = tags
      @name = @repository.name.capitalize
    end

    def build_doc(dir)
      @repository.clone_quickly
      for tag in @tags
        @repository.checkout(tag)
        Documentation.new(self, tag).build(File.join(dir, @repository.name))
      end
    end

    def dir
      @repository.dir
    end
  end

  class Documentation
    def initialize(project, tag)
      @project = project
      @tag = tag
      @version = self.class.tag_to_version(@tag)
      @path = self.class.version_to_path(@version)
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
      versionned_dir = File.join(dir, @path)
      title = "#{@project.name} #{@version} Documentation"
      options = ["--root=#{@project.dir}", "--include=#{@project.dir}/doc", "--title=#{title}", "--main=#{main_file}", "--output=#{versionned_dir}", "--template=rorvswild"]
      RDoc::RDoc.new.document(options)
    end

    def main_file
      ["README.md", "README.rdoc", "README"].find { |file| File.exist?(File.join(@project.dir, file)) }
    end
  end

  class Site
    def self.build(urls_and_tags)
      projects = urls_and_tags.map { |(url, tags)| Project.new(Repository.new(url), tags) }
      projects.each { |project| project.build_doc("_site") }
    end
  end
end
