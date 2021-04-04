ActiveAdmin.register User, as: "User Registration Path" do
  menu parent: 'Users', priority: 3
  filter :origin

  index { render 'index', context: self }

end
