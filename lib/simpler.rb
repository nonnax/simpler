#!/usr/bin/env ruby
# Id$ nonnax 2022-05-09 01:37:27 +0800
class Simpler
  class DummyFix<Rack::Response; end
  H=Hash.new{|h,k|h[k]=k.transform_keys(&:to_sym)}
  
  %i(get post).each do |m|
      define_method( m ){|path, **params, &block|
        block.call(*@captures) if match?(path, m, **params)
      }
  end

  def match?(u, m, **params, &block)
    [req.request_method.downcase==m.to_s, 
    md=req.path_info.match(pattern u)]
    .all?
    .tap { |x|
      yield @captures=(Array(md&.captures)+params.merge(H[req.params]).values).compact if x && block
    }
  end

  def pattern u
    u.gsub(/:\w+/, '([^/?#]+)').then { |s| %r{^#{s}/?$} }
  end

  attr :res, :req, :env
  def initialize(&block)
    @block=block
  end

  def call(env)
    @req=Rack::Request.new(env)
    @res=Rack::Response.new nil, 200
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

