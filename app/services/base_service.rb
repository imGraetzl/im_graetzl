class BaseService
  include Rails.application.routes.url_helpers
  include ActionDispatch::Routing::PolymorphicRoutes

  HTTP_ERRORS = [
   EOFError,
   Errno::ECONNRESET,
   Errno::EINVAL,
   Net::HTTPBadResponse,
   Net::HTTPHeaderSyntaxError,
   Net::ProtocolError,
   Timeout::Error]

  def self.call(*args)
    new(*args).call
  end

  def call
    raise NotImplementedError, "call method not implemented for #{self.class}"
  end
end
