class ZuckerlPublisher

  def expire_published
    Zuckerl.live.find_each{|zuckerl| zuckerl.expire!}
  end

  def publish_drafted(date_range)
    Zuckerl.where(created_at: date_range).find_each do |zuckerl|
      zuckerl.put_live! if zuckerl.may_put_live?
    end
  end
end
