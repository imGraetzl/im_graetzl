Range::RANGE_FORMATS[:readable] = ->(start, stop) { "#{I18n.localize(start, format:'%d. %b. %y')} bis #{I18n.localize(stop, format:'%d. %b. %y')}" }
