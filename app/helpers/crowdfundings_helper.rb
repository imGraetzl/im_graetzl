module CrowdfundingsHelper

  def crowd_benefits_select_options
    CrowdBenefit.order(:title).map do |category|
      ["Ja | Kategorie '#{category.title}'", category.id]
    end
  end

  def runtime_values
    [15, 30, 45, 60].map do |value|
      ["#{value} Tage", value]
    end
  end

  def delivery_week_values
    [
      ["innerhalb 1 Woche", 1],
      ["innerhalb 2 Wochen", 2],
      ["innerhalb 3 Wochen", 3],
      ["innerhalb 1 Monat", 4],
      ["innerhalb 3 Monate", 12],
      ["innerhalb 6 Monate", 24],
      ["innerhalb 9 Monate", 36],
      ["innerhalb 1 Jahr", 48]
    ]
  end

  def billable_values
    [
      ["Nein - Ich stelle keine Rechnungen aus", 'no_bill'],
      ["Ja - Ich stelle Rechnungen aus (ohne Ust.)", 'bill'],
      ["Ja - Ich stelle Rechnungen aus (inkl. 20% Ust.)", 'bill_with_tax']
    ]
  end

end
