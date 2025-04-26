require "bundler/gem_tasks"

require "rdoc"
require "rorvswild_theme_rdoc"

namespace :site do
  task :build do
    RorVsWildThemeRdoc::Site.build(ENV["RUBY_DIR"] || "ruby")
  end
end

module RorVsWildThemeRdoc
  class Site
    def self.build(ruby_dir)
      build_ruby_doc(ruby_dir, %w[master v2_7_0 v3_0_0 v3_1_0 v3_2_0 v3_3_0 v3_4_0])
    end

    def self.build_ruby_doc(ruby_dir, tags)
      for tag in tags
        version = tag_to_version(tag)
        system("git -C #{ruby_dir} checkout #{tag}")
        options = ["--root=#{ruby_dir}", "--include=#{ruby_dir}/doc", "--title=Ruby #{version} Documentation", "--main=README.md", "--output=_site/docs/#{version}", "--template=rorvswild"]
        RDoc::RDoc.new.document(options)
      end
      system("mv _site/docs/master/* _site/") # Master documentation is root site
    end

    # Normalize tag names since Ruby repository uses v3_4_0, but version numbers are written this way 3.4.0.
    def self.tag_to_version(tag)
      version = tag.delete_prefix("v")
      version.gsub!("_", ".")
      version
    end
  end
end

