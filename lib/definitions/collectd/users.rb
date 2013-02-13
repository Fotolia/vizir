graph "users" do
  metric "users_count" do
    rrd %r{users/users.rrd}
    ds "value"
    title "User count"
  end

  layout :line
  title "Users"
  scope :entity
end
