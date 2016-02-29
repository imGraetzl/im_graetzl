module ZuckerlsHelper
  def zuckerl_month(zuckerl)
    time = zuckerl.created_at || Time.now
    I18n.localize time.end_of_month+1.day, format: '%B'
  end

  def zuckerl_month_and_year(zuckerl)
    time = zuckerl.created_at || Time.now
    I18n.localize time.end_of_month+1.day, format: '%B %Y'
  end
end
