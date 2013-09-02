Gem::Specification.new do |s|
  s.name        = 'shaper'
  s.version     = '0.0.0'
  s.summary     = ''
  s.description = ''
  s.authors     = ['Robin Curry', 'Brandon Westcott', 'Tim Morgan']
  s.email       = ['robin.curry@vitals.com', 'brandon.westcott@vitals.com', 'tim.morgan@vitals.com']
  s.homepage    = 'https://github.com/organizations/mdx-dev'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activesupport', '>= 3.0'
end
