class AddSeedCategories < ActiveRecord::Migration
  def up
    say_with_time 'Adding default :business categories...' do
      location_categories = [
        'Kreativwirtschaft / Handwerk',
        'Wohlbefinden & Gesundheit',
        'Unternehmen & Start-ups',
        'Geschäft / Ladenlokal im Grätzl',
        'Gastronomie',
        'Lokaler Dienstleister',
        'Öffentlicher Raum / Sozialer Treffpunkt',
        'Leerstand',
        'Sonstige Tätigkeit']
      location_categories.each do |c|
        Category.create(name: c, context: Category.contexts[:business])
      end
    end

    say_with_time 'Updating existing locations without category...' do
      default_category = Category.business.first
      Location.where(category: nil).each do |l|
        l.update(category: default_category)
      end
    end
  end
end


