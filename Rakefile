require "bundler/gem_tasks"
require "rorvswild_theme_rdoc/site"

namespace :site do
  namespace :build do
    desc "Build docs for Ruby and gems"
    task :docs do
      site.build_docs
    end

    desc "Build site pages (index.html)"
    task :pages do
      site.build_pages
    end
  end

  desc "Build docs and pages"
  task build: ["site:build:docs", "site:build:pages"]

  def site
    @site ||= RorVsWildThemeRdoc::Site.new(
      "https://github.com/ruby/ruby.git" => %w[v3_2_0 v3_3_0 v3_4_0].reverse,
      "rails" => %w[7.1.0 7.2.0 8.0.0].reverse,
      "rdoc" => %w[v6.10.0 v6.11.1 v6.13.1].reverse,
      "gems" => %w[1.1.1 1.2.0 1.3.0].reverse,
    )
  end
end
