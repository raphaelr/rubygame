gem_spec = Gem::Specification.new do |s|
  s.name     = "rubygame"
  s.version  = "2.6.2"
  s.author   = "John Croisant"
  s.email    = "jacius@gmail.com"
  s.homepage = "http://rubygame.org/"
  s.summary  = "Clean and powerful library for game programming"
  s.rubyforge_project = "rubygame"

  s.require_paths = ["lib", "lib/rubygame/"]

  s.required_ruby_version = ">= 1.8"
  s.add_dependency( "rake", ">=0.7.0" )
  s.add_dependency( "ruby-sdl-ffi", ">=0.1.0" )
  s.requirements = ["SDL       >= 1.2.7",
                    "SDL_gfx   >= 2.0.10 (optional)",
                    "SDL_image >= 1.2.3  (optional)",
                    "SDL_mixer >= 1.2.7  (optional)",
                    "SDL_ttf   >= 2.0.6  (optional)"]

end
