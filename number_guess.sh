#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo Enter your username:
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(name) VALUES ('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( 1 + RANDOM % 1000 ))
GUESSES=0

GUESS () {
  echo $1
  read GUESS_NUMBER
  ((GUESSES++))
  if [[ $GUESS_NUMBER =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS_NUMBER > $SECRET_NUMBER ]]
    then
      GUESS "It's lower than that, guess again:"
    elif [[ $GUESS_NUMBER < $SECRET_NUMBER ]]
    then
      GUESS "It's higher than that, guess again:"
    else
      echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      # Increment number of games played by 1
      GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID")
      ((GAMES_PLAYED++))
      UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE user_id = $USER_ID")
      # Update best game result
      BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID")
      if [[ -z $BEST_GAME || $BEST_GAME -gt $GUESSES ]]
      then
        UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $GUESSES WHERE user_id = $USER_ID")
      fi
    fi
  else
    GUESS "That is not an integer, guess again:"
  fi
}

GUESS "Guess the secret number between 1 and 1000:"
