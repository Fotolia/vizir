metric "users_count" do
  rrd %r{users/users.rrd}
  ds "value"
  title "User count"
end

graph "users" do
  metrics [ "users_count" ]
  layout :line
  title "Users"
  scope :entity
end
