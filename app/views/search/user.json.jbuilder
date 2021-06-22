json.array!(@results.select{|r| r.is_a?(User)}) do |user|
  json.type user.class.name
  json.name user.username
  json.first_name user.first_name
  json.last_name user.last_name
  json.id user.id
  json.icon user.avatar_url(:thumb)
end
