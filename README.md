*Secure Voting System*

 - This repository contains a Ruby script for a secure voting application. The project demonstrates basic principles of secure voting by implementing user authentication and encrypted vote handling.
   

*Overview*

 - The script allows users to register, authenticate, cast votes, and tally results. It uses encryption to securely store votes and hashed passwords for user authentication.


*Prerequisites*

 - To run the script, you need Ruby 3.0.0 or higher and the following gems:
   *bcrypt for password hashing
   *sqlite3 for database management
   *openssl for encryption
  

*Code Overview*

 - Functions
   *register_user.rb:
    Registers a new user with a hashed password.

    Parameters: Username, password.
    Description: Prompts the user for username and password, then saves the hashed password to the database.

   *cast_vote.rb: Allows an authenticated user to cast a vote.

    Parameters: Username, password, vote.
    Description: Authenticates the user, then encrypts and stores the vote.
   
   *tally_votes.rb: Displays the total number of votes.

    Parameters: None.
    Description: Decrypts the stored votes and displays the tally.
