#!/usr/bin/env ruby
# Id$ nonnax 2022-05-09 01:37:27 +0800
class Simpler
  class DummyFix<Rack::Response; end
  
  %i(get post).each do |m|
    define_method( m ){|path, **opts, &block|
      match?(path, m){|slugs| @captures=(slugs+param_values(**opts)).compact }
      .then{|x| block.call(*@captures) if x}
    }
  end

  def param_values(**opts)
    opts
    .merge(req.params.transform_keys(&:to_sym))
    .values
  end

  def match?(path, m, &block)
    [
      md=req.path_info.match(pattern path), 
      req.request_method.downcase==m.to_s
    ]
    .all?
    .tap{|x| yield Array(md&.captures) if x}
  end

  def pattern u
    u.gsub(/:\w+/,'([^/?#]+)').then{ |s| %r{^#{s}/?$} }
  end

  attr :res, :req, :env
  def initialize(&block)
    @block=block
    @captures=[]
  end

  def call(env)
    @req=Rack::Request.new(env)
    @res=Rack::Response.new(nil, 200)
    @env=env
    instance_eval(&@block)
    default{ res.write 'Not Found' }
    res.finish
  end

  def default
    yield(res.status=404) if res.status==200 && res.body.empty?
  end

  def session
    env['rack.session']
  end

end

