require 'sqlite3'
require 'singleton'

class QuestionsDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Questions

  attr_accessor :id

   def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM questions")
    data.map { |datum| Questions.new(datum) }
  end

  def self.find_by_author(author_id)
    results = QuestionsDBConnection.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.u_id = ?
    SQL
    
    results.map {|result| Questions.new(result) }
  end

  def self.most_followed(n)
    QuestionFollows.most_followed_questions(n)
  end

  def followers
    QuestionFollows.followers_for_question_id(@id)
  end

  def initialize(datum)
    @id = datum['id']
    @title = datum['title']
    @body= datum['body']
    @u_id = datum['u_id']
  end


end

class Users
  attr_accessor :fname , :lname, :id
  

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM users")
    data.map { |datum| Users.new(datum) }
  end

  def self.find_by_id(query_id)
    result = QuestionsDBConnection.instance.execute(<<-SQL, query_id)
      SELECT 
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    Users.new(result.first)
  end

  def self.find_by_name(fname, lname)
    result = QuestionsDBConnection.instance.execute(<<-SQL, fname, lname)
      SELECT 
        *
      FROM
        users
      WHERE
        users.fname = ? AND users.lname = ?
    SQL

    Users.new(result.first)
  end
  
  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def followed_questions
    QuestionFollows.followed_questions_for_user_id(@id)
  end

end


class QuestionFollows

  def self.most_followed_questions(n)
    results = QuestionsDBConnection.instance.execute(<<-SQL, n)
    SELECT
      questions.*
    FROM questions
    WHERE questions.id IN
      (
        SELECT
          q_id
        FROM
          question_follows
        GROUP BY
          q_id
        ORDER BY COUNT(u_id) DESC
        LIMIT ?
        )
    SQL

    results.map {|result| Questions.new(result)}
  end

  def self.followers_for_question_id(q_id)
    result = QuestionsDBConnection.instance.execute(<<-SQL, q_id)
      SELECT 
        users.*
      FROM question_follows
      JOIN users on question_follows.u_id = users.id
      JOIN questions on question_follows.q_id = questions.id
      WHERE
        questions.id = ?
    SQL

    result.map {|result| Users.new(result) }
  end

  def self.followed_questions_for_user_id(user_id)
    result = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT 
        questions.*
      FROM question_follows
      JOIN users on question_follows.u_id = users.id
      JOIN questions on question_follows.q_id = questions.id
      WHERE
        users.id = ?
    SQL

    result.map {|result| Questions.new(result) }

  end

  
  def initialize(datum)
    @q_id = datum['q_id']
    @u_id = datum['u_id']
  end

end

class Replies
  def self.find_by_user_id(u_id)
    result = QuestionsDBConnection.instance.execute(<<-SQL, u_id)
      SELECT 
        *
      FROM
        replies
      WHERE
        u_id = ?
    SQL

    result.map {|result| Replies.new(result) }
  end

  def self.find_by_question_id(q_id)
    result = QuestionsDBConnection.instance.execute(<<-SQL, q_id)
      SELECT 
        *
      FROM
        replies
      WHERE
        q_id = ?
    SQL

    replies_to_q = []
    result.each do |result|
      replies_to_q << Replies.new(result)
    end
    replies_to_q
  end
  
  def initialize(datum)
    @id = datum['id']
    @parent_id = datum['parent_id']
    @body= datum['body']
    @q_id = datum['q_id']
    @u_id = datum['u_id']
  end


end

class QuestionLike

  def self.likers_for_question_id(question_id)
    result = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM question_likes
      JOIN users ON users.id = question_likes.u_id
      WHERE q_id = ?
    SQL

    result.map {|result| Users.new(result)}
  end

  def self.num_likes_for_question_id(question_id)
    result = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        count(*) as count
      FROM question_likes
      WHERE q_id = ?
      GROUP BY q_id
    SQL

    result.first["count"]
  end

  def initialize(datum)
    @q_id = datum['q_id']
    @u_id = datum['u_id']
  end

  def self.liked_questions_for_user_id(user_id)
    results = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_likes
      JOIN 
        users ON users.id = question_likes.u_id
      JOIN
        questions ON questions.id = question_likes.q_id
      WHERE 
        users.id = ?
    SQL

    results.map {|result| Questions.new(result)}
  end

  
end