module ZuckerlsHelper
  def zuckerl_month(zuckerl)
    time = zuckerl.created_at || Time.now
    I18n.localize time.end_of_month+1.day, format: '%B %Y'
  end
end
