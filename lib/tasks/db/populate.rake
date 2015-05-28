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
    [User, Meeting, Category, PublicActivity::Activity].each(&:destroy_all)
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
      admin: true,
      graetzl: Graetzl.first,
      confirmed_at: Time.now)
    admin.save(validate: false)
    user_1 = User.new(
      username: 'user_1',
      first_name: 'user_1',
      last_name: 'user_1',
      email: 'user_1@example.com',
      password: 'user_1',
      password_confirmation: 'user_1',
      admin: false,
      graetzl: Graetzl.limit(1).offset(1).first,
      confirmed_at: Time.now)
    user_1.save(validate: false)
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