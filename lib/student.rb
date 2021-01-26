require_relative "../config/environment.rb"

class Student

  attr_reader :id
  attr_accessor :name, :grade

  def initialize(name, grade, id=nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = "CREATE TABLE students ( id INTEGER PRIMARY KEY, name TEXT, grade INTEGER );"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE students;"
    DB[:conn].execute(sql)
  end

  def save
    if self.id == nil
      sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?);
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students;")[0][0]
    else
      self.update
    end
  end

  def self.all
    all_rows = DB[:conn].execute("SELECT * FROM students;")
    all_students = all_rows.map { |row| Student.new_from_db(row) }
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?;"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    student = Student.new(name, grade)

    student.save
  end

  def self.new_from_db(row)
    student = Student.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    Student.all.find { |student| student.name == name }
  end

end
