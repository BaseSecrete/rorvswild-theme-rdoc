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
      "https://github.com/ruby/ruby.git" => "3.2",
      "https://github.com/rails/rails.git" => "7.1",
      "addressable" => "2.6",
      "bundler" => "2.4",
      "concurrent-ruby" => "1.1",
      "diff-lcs" => "1.4",
      "faraday" => "2.11",
      "ffi" => "1.15",
      "gems" => "1.1",
      "i18n" => "1.9",
      "json" => "2.9",
      "mime-types" => "3.4",
      "minitest" => "5.23",
      "multi_json" => "1.13",
      "nokogiri" => "1.16",
      "public_suffix" => "5.1",
      "rack" => "2.2",
      "rake" => "13.0",
      "rdoc" => "6.10",
      "https://github.com/rspec/rspec.git" => "3.13",
      "thor" => "1.1",
      "tzinfo" => "1.1",
    )
  end
end
