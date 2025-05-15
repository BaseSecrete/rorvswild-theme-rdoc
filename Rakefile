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
    @site ||= RorVsWildThemeRdoc::Site.new([
      {source: "https://github.com/ruby/ruby.git", min_version: "3.2"},
      {source: "https://github.com/rails/rails.git", min_version: "7.1"},
      {
        source: "https://github.com/BaseSecrete/active_hashcash.git",
        min_version: "0.4.0",
        fitter: {copy: ["active_hashcash_dashboard.png", "demo.gif", "logo.png", "rorvswild_logo.jpg"]},
      },
      {source: "addressable", min_version: "2.6"},
      {source: "bundler", min_version: "2.4"},
      {source: "diff-lcs", min_version: "1.4"},
      {
        source: "https://github.com/lostisland/faraday.git",
        min_version: "2.11",
        fitter: {copy: ["docs/_media/home-logo.svg"]},
      },
      {source: "ffi", min_version: "1.15"},
      {source: "gems", min_version: "1.1"},
      {source: "i18n", min_version: "1.9"},
      {source: "json", min_version: "2.9"},
      {source: "mime-types", min_version: "3.4"},
      {source: "minitest", min_version: "5.23"},
      {source: "multi_json", min_version: "1.13"},
      {source: "nokogiri", min_version: "1.16"},
      {source: "public_suffix", min_version: "5.1"},
      {
        source: "https://github.com/rack/rack.git",
        min_version: "2.2",
        fitter: {copy: ["contrib/rack.png", "contrib/logo.webp"]},
      },
      {source: "rake", min_version: "13.0"},
      {source: "rdoc", min_version: "6.10"},
      {source: "https://github.com/rspec/rspec.git", min_version: "3.13"},
      {source: "stimulus-rails", min_version: "1.3"},
      {source: "thor", min_version: "1.1"},
      {source: "tzinfo", min_version: "1.1"},
    ])
  end
end
