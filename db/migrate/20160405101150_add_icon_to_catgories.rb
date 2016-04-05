class AddIconToCatgories < ActiveRecord::Migration
  def up
    add_column :categories, :icon, :string
    say_with_time 'Add icons to existing business catgories' do
      Category.business.find_each do |category|
        case category.name
        when 'Wohlbefinden & Gesundheit'
          category.update icon: 'icon-leaf'
        when 'Geschäft / Ladenlokal im Grätzl'
          category.update icon: 'icon-sale-label'
        when 'Kreativwirtschaft / Handwerk'
          category.update icon: 'icon-painting-palette'
        when 'Lokaler Dienstleister'
          category.update icon: 'icon-pin'
        when 'Unternehmen & Start-ups'
          category.update icon: 'icon-mouse'
        when 'Gastronomie'
          category.update icon: 'icon-tea-cup'
        when 'Öffentlicher Raum / Sozialer Treffpunkt'
          category.update icon: 'icon-tree'
        end
      end
    end
  end

  def down
    remove_column :categories, :icon, :string
  end
end
