require "bundler/gem_tasks"

require "rdoc"
require "rorvswild_theme_rdoc"

namespace :site do
  task :build do
    RorVsWildThemeRdoc::Site.build(ruby: ENV["RUBY_DIR"] || "ruby", rails: ENV["RAILS_DIR"] || "rails")
  end
end

module RorVsWildThemeRdoc
  class Site
    @ruby_tags = %w[master v2_7_0 v3_0_0 v3_1_0 v3_2_0 v3_3_0 v3_4_0]
    @rails_tags = %w[main v6.0.0 v6.1.0 v7.0.0 v7.1.0 v7.2.0 v8.0.0]

    def self.build(dirs)
      build_doc(dirs[:ruby], @ruby_tags, "Ruby %{version} Documentation") if dirs[:ruby]
      build_doc(dirs[:rails], @rails_tags, "Rails %{version} Documentation") if dirs[:rails]
      system("mv _site/ruby/master/* _site/") if File.exist?("_site/ruby/master")
    end

    def self.build_doc(repository_dir, tags, title)
      for tag in tags
        system("git -C #{repository_dir} checkout #{tag}")
        version = tag_to_version(tag)
        versionned_title = title % {version: version}
        site_dir =  File.join("_site", File.basename(repository_dir), version)
        options = ["--root=#{repository_dir}", "--include=#{repository_dir}/doc", "--title=#{versionned_title}", "--main=README.md", "--output=#{site_dir}", "--template=rorvswild"]
        RDoc::RDoc.new.document(options)
      end
    end

    # Normalize tag names since Ruby repository uses v3_4_0, but version numbers are written this way 3.4.0.
    def self.tag_to_version(tag)
      version = tag.delete_prefix("v")
      version.gsub!("_", ".")
      version
    end
  end
end
