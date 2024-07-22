require 'sqlite3'
require 'bcrypt'
require 'openssl'
require 'base64'

# Database setup
DB = SQLite3::Database.new 'db.sqlite3'

DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE,
    password_digest TEXT
  );
SQL

DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS votes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    encrypted_vote TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id)
  );
SQL

# Encrypt and decrypt methods
def encrypt_data(data, password)
  cipher = OpenSSL::Cipher.new('AES-256-CBC')
  cipher.encrypt
  key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(password, 'salt', 20000, cipher.key_len)
  iv = cipher.random_iv
  cipher.key = key
  cipher.iv = iv

  encrypted = cipher.update(data) + cipher.final
  Base64.encode64(iv + encrypted)
end

def decrypt_data(encrypted_data, password)
  decoded_data = Base64.decode64(encrypted_data)
  cipher = OpenSSL::Cipher.new('AES-256-CBC')
  cipher.decrypt
  key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(password, 'salt', 20000, cipher.key_len)
  iv = decoded_data.slice!(0, cipher.iv_len)
  cipher.key = key
  cipher.iv = iv

  cipher.update(decoded_data) + cipher.final
end

# User registration
def register_user(username, password)
  password_digest = BCrypt::Password.create(password)
  DB.execute('INSERT INTO users (username, password_digest) VALUES (?, ?)', [username, password_digest])
  puts "User registered successfully."
end

# User authentication
def authenticate_user(username, password)
  user = DB.execute('SELECT * FROM users WHERE username = ?', [username]).first
  return false unless user
  BCrypt::Password.new(user[2]) == password
end

# Cast vote
def cast_vote(username, password, vote)
  return unless authenticate_user(username, password)

  user = DB.execute('SELECT id FROM users WHERE username = ?', [username]).first
  encrypted_vote = encrypt_data(vote, password)
  DB.execute('INSERT INTO votes (user_id, encrypted_vote) VALUES (?, ?)', [user[0], encrypted_vote])
  puts "Vote cast successfully."
end

# Tally votes
def tally_votes(password)
  votes = DB.execute('SELECT encrypted_vote FROM votes')
  decrypted_votes = votes.map { |v| decrypt_data(v[0], password) }
  tally = decrypted_votes.each_with_object(Hash.new(0)) { |vote, hash| hash[vote] += 1 }
  tally.each { |candidate, count| puts "#{candidate}: #{count} votes" }
end

# Command-line interface
def main
  puts "1. Register\n2. Login and Vote\n3. Tally Votes"
  choice = gets.chomp.to_i

  case choice
  when 1
    puts "Enter username:"
    username = gets.chomp
    puts "Enter password:"
    password = gets.chomp
    register_user(username, password)
  when 2
    puts "Enter username:"
    username = gets.chomp
    puts "Enter password:"
    password = gets.chomp
    puts "Enter your vote:"
    vote = gets.chomp
    cast_vote(username, password, vote)
  when 3
    puts "Enter the password to decrypt votes:"
    password = gets.chomp
    tally_votes(password)
  else
    puts "Invalid choice."
  end
end

main