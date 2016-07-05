class BaseApiMailer
  def self.deliver(*args)
    new(*args).deliver
  end

  def deliver
    raise NotImplementedError, "deliver method not implemented for #{self.class}"
  end
end
