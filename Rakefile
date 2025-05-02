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
  task build: ["site:build:pages", "site:build:docs"]

  def site
    @site ||= RorVsWildThemeRdoc::Site.new(
      "https://github.com/ruby/ruby.git" => %w[v3_2_0 v3_3_0 v3_4_0].reverse,
      "https://github.com/rails/rails.git" => %w[v7.1.0 v7.2.0 v8.0.0].reverse,
      "bundler" => %w[2.4.22 2.5.23 2.6.8].reverse,
      "concurrent-ruby" => %w[1.1.10 1.2.3 1.3.5].reverse,
      "gems" => %w[1.1.1 1.2.0 1.3.0].reverse,
      "i18n" => %w[1.9.1 1.13.0 1.14.7].reverse,
      "json" => %w[2.11.3 2.10.1 2.9.1].reverse,
      "minitest" => %w[5.23.1 5.24.1 5.25.5].reverse,
      "nokogiri" => %w[1.18.8 1.17.2 1.16.8].reverse,
      "rack" => %w[2.2.13 3.0.15 3.1.13].reverse,
      "rake" => %w[13.0.6 13.1.0 13.2.1].reverse,
      "rdoc" => %w[v6.10.0 v6.11.1 v6.13.1].reverse,
      "https://github.com/rspec/rspec.git" => %w[rspec-core-v3.13.4].reverse,
      "tzinfo" => %w[1.1.0 1.2.11 2.0.6].reverse,
    )
  end
end
