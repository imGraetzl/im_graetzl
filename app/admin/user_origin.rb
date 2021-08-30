ActiveAdmin.register User, as: "User Registration Path" do
  menu parent: 'Users'
  filter :origin

  index { render 'index', context: self }

end
