#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'sqlite3'

def get_db
	SQLite3::Database.new 'barbershop.sqlite3'
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
	'Gustavo "The Cousins" Salamanca'
]

configure do
	db = get_db
	db.execute 'CREATE TABLE IF NOT EXISTS 
	"Users"
	(
		"id" integer PRIMARY KEY AUTOINCREMENT NOT NULL,
		"Name" varchar(128),
		"Phone" varchar(128),
		"DateStamp" varchar(128),
		"Barber" varchar(128),
		"Color" varchar(128)
	)'
	db.execute 'CREATE TABLE IF NOT EXISTS 
	"Barbers"
	(
			"id" integer PRIMARY KEY AUTOINCREMENT NOT NULL,
			"Name" varchar(128)
	)'

	barbers.each do |name|
		exists = db.execute("SELECT COUNT(*) FROM Barbers WHERE name = ?", name)[0][0]
		if exists == 0
			db.execute("INSERT INTO Barbers (name) VALUES (?)", name)
		end
	end
	
end


get '/' do
	erb "Best Barber shop app.rb"	
end

get "/about" do
	erb :about
end

get "/appointment" do
	@db = get_db
@db.results_as_hash = true

	erb :appointment
end

get "/contacts" do
	erb :contacts
end

get '/showusers' do
	@db = get_db
	@db.results_as_hash = true
	
  erb :showusers
end

post "/appointment" do
	@username = params[:username]
	@tel = params[:tel]
	@date = params[:date]
	@barber = params[:barber]
	@color = params[:color]

	hh = { 
		:username => "Введите Имя",
		:tel => "Введите Телефон",
		:date => "Введите Дату",
		:barber => "Выберите Барбера",
		:color => "Выберите цвет "
	}
	@db = get_db
	@db.results_as_hash = true
	errors_show hh

	if @error != ""
		return erb :appointment
	end
	
	get_db.execute 'insert into 
	Users 
		(
			Name,
			Phone,
			DateStamp,
			Barber,
			Color
		)
		values(?,?,?,?,?)', [@username, @tel, @date, @barber, @color]

	# Запись в .txt file
	# f = File.open "./public/users.txt", "a"
	# f.write "Username: #{@username}, Phone: #{@tel}, Date: #{@date}, Barber: #{@barber}, Color: #{@color}\n"
	# f.close

	erb "Спасибо за запись!\nUsername: #{@username}, Phone: #{@tel}, Date: #{@date}, Barber: #{@barber}, Color: #{@color}"
end

post "/contacts" do
	email = params[:email]
	message = params[:message]

	hh = { 
		:email => "Введите Имейл",
		:message => "Введите Сообщение"
	}

	errors_show hh

	if @error != ""
		return erb :contacts
	end
	
	Pony.options = {
		via: :smtp,
		via_options: {
			address: 'smtp.gmail.com',
			port: '587',
			enable_starttls_auto: true,
			user_name: '',
			password: '',
			authentication: :plain,
			domain: 'localhost:4567'
		}
	}

	Pony.mail(
		:to => '', 
		:from => email,
		:reply_to => email,
		:sender => email,
		:subject => 'Test Mail', 
		:body => message,
	)

 erb "Email sent successfully!" 
end

def errors_show hash
	@error = hash.select { |key, _| params[key] == ""}.values.join(", ")
end
