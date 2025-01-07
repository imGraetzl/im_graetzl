ActiveAdmin::Comment.class_eval do
  default_scope { order(created_at: :desc) } # Jüngste Kommentare zuerst
end