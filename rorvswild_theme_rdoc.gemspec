lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = "rorvswild_theme_rdoc"
  s.version = "0.1"

  s.authors = ["Antoine Marguerie", "Alexis Bernard"]
  s.description = " RDoc theme for developers with sensitive eyes."
  s.summary = " RDoc theme for developers with sensitive eyes."
  s.homepage = "https://www.rorvswild.com/theme"
  s.email = ""
  s.license = 'MIT'

  s.require_path = 'lib'
  s.files  = ["lib"]
end
