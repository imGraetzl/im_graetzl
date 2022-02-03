ActiveAdmin.register CrowdBenefit do
  menu parent: 'Crowdfunding'

  index { render 'index', context: self }
  form partial: 'form'

  permit_params :title

end
