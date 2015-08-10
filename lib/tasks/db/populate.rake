namespace :db do
  desc 'Erase and fill db with sample data'
  task populate: :environment do

    puts 'remove old data'

    [User, Meeting, Category, Post, PublicActivity::Activity].each(&:destroy_all)

    puts 'check for graetzl and districts'

    if Graetzl.all.empty? || District.all.empty?
      puts 'invoke db:seed'
      Rake::Task['db:seed'].invoke
    end

    puts 'add users'

    users = ['malano', 'mirjam', 'jack', 'peter', 'jeanine', 'max', 'tawan']
    users.each do |user|
      new_user = User.new(
        username: user,
        first_name: user,
        last_name: user,
        email: user + '@example.com',
        password: 'secret',
        role: :admin,
        graetzl: Graetzl.find_by_name('Stuwerviertel'),
        confirmed_at: Time.now)
      File.open(Rails.root+"public/avatars/#{user}.gif", 'rb') do |file|
        new_user.avatar = file
      end
      new_user.save(validate: false)
    end

    user_1 = User.create(
      username: 'user_1',
      first_name: 'user_1',
      last_name: 'user_1',
      email: 'user_1@example.com',
      password: 'secret',
      graetzl: Graetzl.first,
      confirmed_at: Time.now)
    File.open(Rails.root+'public/avatars/user_1.jpg', 'rb') do |file|
      user_1.avatar = file
    end
    user_1.save(validate: false)

    puts 'add categories'

    meeting_categories = [
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

    meeting_categories.each do |c|
      Category.create(name: c)
    end
  end  
end