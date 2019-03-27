PRAGMA foreign_keys = ON;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR NOT NULL, 
  lname VARCHAR NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR NOT NULL,
  body VARCHAR NOT NULL,
  u_id INTEGER NOT NULL,

  FOREIGN KEY (u_id) REFERENCES users(id) 
);

CREATE TABLE question_follows (
  q_id INTEGER NOT NULL,
  u_id INTEGER NOT NULL,

  FOREIGN KEY (q_id) REFERENCES questions(id),
  FOREIGN KEY (u_id) REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body VARCHAR NOT NULL,
  q_id INTEGER NOT NULL,
  u_id INTEGER NOT NULL,
  parent_id INTEGER,


  FOREIGN KEY (parent_id) REFERENCES replies(id), 
  FOREIGN KEY (q_id) REFERENCES questions(id),
  FOREIGN KEY (u_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
  q_id INTEGER NOT NULL,
  u_id INTEGER NOT NULL,

  FOREIGN KEY (q_id) REFERENCES questions(id),
  FOREIGN KEY (u_id) REFERENCES users(id)
);

INSERT INTO 
  users ( fname, lname )
VALUES
  ('Stefan', 'Dabroski'),
  ('Nhat', 'Do');

INSERT INTO
  questions (title, body, u_id)
VALUES
  ("To Be Or Not To Be?", "This is the essential question.", ( SELECT id FROM users WHERE fname = 'Stefan')),
  ("What is the Meaning of Life?", "Nobody knows.", ( SELECT id FROM users WHERE fname = 'Nhat'));
