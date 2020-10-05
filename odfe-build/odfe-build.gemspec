Gem::Specification.new do |s|
  s.name        = 'odfe-build'
  s.version     = '0.1.0'
  s.licenses    = ['Apache-2.0']
  s.summary     = 'This gem provides the OpenDistro for Elasticsearch build tools'
  s.description = 'The odfe-build gem provides the command-line tools and libraries used for the ODFE Anytime Build project. These tools allow developers to compile Elasticsearch, Kibana, and plugins from source; bundle them into an ODFE distribution; test the distribution on a local or remote cluster; and release distribution artifacts to various public repositories.'
  s.authors     = ['The OpenDistro for Elasticsearch team']
  s.files        = Dir['lib/**/*.rb', 'bin/*', 'LICENSE', 'README.md']
  s.homepage    = 'https://opendistro.github.io/for-elasticsearch/'
  s.metadata    = { 'source_code_uri' => 'https://github.com/opendistro-for-elasticsearch/opendistro-build' }

  s.add_runtime_dependency 'aws-sdk', '~>3'
end
