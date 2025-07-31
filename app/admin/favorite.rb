ActiveAdmin.register Favorite do
  menu parent: 'Users'
  actions :all, except: [:new, :edit, :destroy]

  scope :all, default: true
  
  filter :user_id_eq, label: "User Suche", as: :string, input_html: {
    class: 'admin-autocomplete-component',
    placeholder: 'Name, Username oder E-Mail ...',
    data: { autocomplete_url: '/admin/autocomplete/users', target_input: 'q[user_id_eq]' }
  }
  filter :favoritable_type, include_blank: true, input_html: { class: 'admin-filter-select'}


  index { render 'index', context: self }

end
