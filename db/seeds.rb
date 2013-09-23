require 'dibber'
Seeder = Dibber::Seeder

Seeder.monitor User
email = 'robnichols@warwickshire.gov.uk'
password = 'change_me'
User.create!(
  :email => email,
  :password => password,
  :password_confirmation => password
) unless User.exists?(:email => email)

puts Seeder.report
