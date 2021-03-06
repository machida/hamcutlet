require 'sinatra'
require 'tempfile'
require 'tmpdir'
require 'haml/html'

class App < Sinatra::Base
  configure do
    use Rack::Static, :urls => ['/images'], :root => 'public'
    set :app_file, __FILE__
    set :haml, {:attr_wrapper => '"', :ugly => false}
    set :sass, {:style => :expanded}
  end

  helpers do
    alias h escape_html
  end

  get '/' do
    haml :index
  end

  post '/' do
    params[:source].gsub!(/\r\n/, "\n")
    params[:source].gsub!(/\r/, "\n")
    params[:source].gsub!(/\n\n/m, "\n")
    params[:source].gsub!(/<!-.*?-->/m, "") # strip comment
    params[:source].gsub!(/\t/, '    ')

    @haml = Haml::HTML.new(params[:source]).render
    @html = Haml::Engine.new(@haml, :attr_wrapper => '"').render
    haml :created
  end

  get '/*.css' do |path|
    content_type 'text/css'
    sass path.to_sym, :sass => {:load_paths => [options.views]}
  end

  get '/*' do |path|
    pass unless File.exist?(File.join(options.views, "#{path}.haml"))
    haml path.to_sym
  end
end
