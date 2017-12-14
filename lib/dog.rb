class Dog
	attr_accessor :name, :breed
	attr_reader :id

	def initialize(params)
		@name = params[:name]
		@breed = params[:breed]
		@id = params[:id]
	end

	def save
		if self.id
			self.update
		else
			sql = <<-SQL
			INSERT INTO dogs (name, breed) VALUES
			(?, ?)
			SQL
			DB[:conn].execute(sql, [name, breed])
			@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		end
		self
	end

	def update
		sql = <<-SQL
		UPDATE dogs
		SET name = ?, breed	= ?
		WHERE id =?
		SQL
		DB[:conn].execute(sql, [name, breed, id])
		self
	end

	def self.create_table
		sql = <<-SQL
		CREATE TABLE IF NOT EXISTS dogs (
			id INTEGER PRIMARY KEY,
			name TEXT,
			breed TEXT);
		SQL
		DB[:conn].execute(sql)
	end

	def self.drop_table
		DB[:conn].execute("DROP TABLE IF EXISTS dogs")
	end

	def self.create(params)
		dog = Dog.new(params)
		dog.save
	end

	def self.new_from_db(array)
		params = {}
		params[:id] = array[0]
		params[:name] = array[1]
		params[:breed] = array[2]
		dog = Dog.new(params)
	end

	def self.find_by_name(name)
		sql = <<-SQL
		SELECT * FROM dogs
		WHERE name = ? LIMIT 1
		SQL
		dog_data = DB[:conn].execute(sql, [name]).first
		dog = new_from_db(dog_data)
	end

	def self.find_by_id(id)
		sql = <<-SQL
		SELECT * FROM dogs
		WHERE id = ?
		SQL
		dog_data = DB[:conn].execute(sql, [id]).first
		new_from_db(dog_data)
	end

	def self.find_or_create_by(params)
		sql = <<-SQL
		SELECT * FROM dogs
		WHERE name = ? AND breed = ?
		SQL
		dog_data = DB[:conn].execute(sql, [params[:name], params[:breed]]).first
		if dog_data
			new_from_db(dog_data)
		else
			Dog.create(params)
		end
	end

end
