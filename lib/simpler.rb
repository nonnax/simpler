#!/usr/bin/env ruby
# Id$ nonnax 2022-05-09 01:37:27 +0800
class Simpler
  class DummyFix<Rack::Response; end
  %i(get post).each do |m|
      define_method( m ){|path, **opts, &block|
        block.call(*capture(**opts).values) if match?(path, m)
      }
  end

  def capture(**opts)
    opts.merge(req.params.transform_keys(&:to_sym))
  end

  def match?(path, m)
    req.path_info.match(/#{path}\/?\Z/) && req.request_method.downcase==m.to_s
  end

  attr :res, :req, :env
  def initialize(&block)
    @block=block
  end

  def call(env)
    @req=Rack::Request.new(env)
    @res=Rack::Response.new
    @env=env
    res.status=200
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

