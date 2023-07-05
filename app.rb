# encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'sqlite3'

def get_db
  db = SQLite3::Database.new 'barbershop.sqlite3'
  db.results_as_hash = true
  return db
end

barbers = [
  'Saul Goodman',
  'Mike Ehrmantraut',
  'Skyler White',
  'Hank Schrader',
  'Tuco Salamanca',
  'Lydia Rodarte-Quayle',
  'Todd Alquist',
  'Marie Schrader',
  'Jane Margolis',
  'Gustavo Salamanca'
]

configure do
  db = get_db
  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS "Users"
    (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      "Name" VARCHAR(128),
      "Phone" VARCHAR(128),
      "DateStamp" VARCHAR(128),
      "Barber" VARCHAR(128),
      "Color" VARCHAR(128)
    )
  SQL

  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS "Barbers"
    (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      "Name" VARCHAR(128)
    )
  SQL

  barbers.each do |name|
    exists = db.execute("SELECT COUNT(*) FROM Barbers WHERE name = ?", name)[0][0]
    if exists.zero?
      db.execute("INSERT INTO Barbers (name) VALUES (?)", name)
    end
  end
end

get '/' do
  erb "Best Barber shop app.rb"
end

get '/about' do
  erb :about
end

get '/appointment' do
  db = get_db
  @barbers = db.execute 'select * from Barbers'

  erb :appointment
end

get '/contacts' do
  erb :contacts
end

get '/showusers' do
  db = get_db
  @results = db.execute 'select*from Users order by id asc'
  
  erb :showusers
end

post '/appointment' do
  @username = params[:username]
  @tel = params[:tel]
  @date = params[:date]
  @barber = params[:barber]
  @color = params[:color]

  hh = {
    username: 'Введите Имя',
    tel: 'Введите Телефон',
    date: 'Введите Дату',
    barber: 'Выберите Барбера',
    color: 'Выберите цвет'
  }

  errors_show(hh)

  if @error != ''
    return erb :appointment
  end

  get_db.execute <<-SQL, [@username, @tel, @date, @barber, @color]
    INSERT INTO Users
    (
      Name,
      Phone,
      DateStamp,
      Barber,
      Color
    )
    VALUES (?, ?, ?, ?, ?)
  SQL

  erb "Спасибо за запись! Username: #{@username}, Phone: #{@tel}, Date: #{@date}, Barber: #{@barber}, Color: #{@color}"
end

post '/contacts' do
  email = params[:email]
  message = params[:message]

  hh = {
    email: 'Введите Имейл',
    message: 'Введите Сообщение'
  }

  errors_show(hh)

  if @error != ''
    return erb :contacts
  end

  # Pony.options = {
  #   via: :smtp,
  #   via_options: {
  #     address: 'smtp.gmail.com',
  #     port: '587',
  #     enable_starttls_auto: true,
  #     user_name: '',
  #     password: '',
  #     authentication: :plain,
  #     domain: 'localhost:4567'
  #   }
  # }

  # Pony.mail(
  #   to: '',
  #   from: email,
  #   reply_to: email,
  #   sender: email,
  #   subject: 'Test Mail',
  #   body: message
  # )

  erb 'Email sent successfully!'
end

def errors_show(hash)
  @error = hash.select { |key, _| params[key] == '' }.values.join(', ')
end
