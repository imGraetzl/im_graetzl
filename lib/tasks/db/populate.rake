namespace :db do
  desc 'Erase and fill db with sample data'
  task populate: :environment do
    erase_old_data
    check_for_graetzl_data
    add_users
    add_categories
  end

  def erase_old_data
    puts 'remove old data'
    [User, Meeting, Category].each(&:destroy_all)
  end

  def check_for_graetzl_data
    if Graetzl.all.empty?
      puts 'import graetzl data first'
      Rake::Task['import_graetzl'].invoke
    end
  end

  def add_users
    admin = User.new(
      username: 'admin',
      first_name: 'admin',
      last_name: 'admin',
      email: 'admin@example.com',
      password: 'admin',
      password_confirmation: 'admin',
      graetzl: Graetzl.first,
      confirmed_at: Time.now)
    admin.save(validate: false)
  end

  def add_categories
    default_categories = [
      'Essen & Trinken',
      'Leute kennenlernen',
      'Neu in der Stadt',
      'Musik machen',
      'Gemeinsam Sport machen',
      'Ausgehen',
      'Kultur',
      'Kinder',
      'Malen und Zeichnen',
      'Swingerclubs',
      'Modelbau',
      'Aquaristik',
      'Kunst und Forschung']

    default_categories.each do |c|
      Category.create(name: c).save!
    end
  end
  
end