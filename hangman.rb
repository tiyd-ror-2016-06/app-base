#  Hangman

require "pry"
require "./db/setup"
require "./lib/all"
valid_words = []
guess_list = []
allowed_chars = ("a".."z").to_a

def load_words (file, min, max)

  # load in words from file that are of lengths between min and max
  print "Loading words ...\n"

  File.open(file, "r").map  { |x| x.chomp }.select do |line|
      line.length <= max && line.length >= min
  end
end

def get_letter_freq_ascending(lines)

  # returns a hash with frequency of each letter in ascending order

  h = ("a".."z").map { |x| [x,0] }.to_h

  lines.each do |item|
    item.split("").each do |letter|
      letter.downcase!
      h.include? letter && h[letter] += 1
    end
  end

  h = h.sort_by { |a, b| b }
  h = h.map { |a,b| a }

  return h
end

def play_again?
  while true
    print "Would you like to play again? (y/n) "
    response = gets.chomp
    if response == "y"
      return true
    elsif response == "n"
      return false
    else
      next
    end
  end
end

def get_hint(sorted_letters, correct_guesses, word, guess_list)

  # submit an hint that will reduce the remaining letters to guess by one

  allowed_hints = sorted_letters - correct_guesses.uniq - guess_list.uniq
  index = 0

  until index == allowed_hints.length - 1
    unless word.include? allowed_hints[index]
      allowed_hints.delete_at(index)
      next
    else
      index += 1
    end
  end

  return allowed_hints[0]
end

def print_score correct_guesses
  correct_guesses.each do |x|
    print x
    print " "
  end
end

def print_end_msg(letters, win)

  print "\nThe game has ended.\n"
  print win ? "You win!" : "You lose!"
  print "\n\nThe word was " + letters.join + ".\n\n"

end

def print_screen(guesses_allowed, hints, correct_guesses)

  system ("clear")

  puts "H A N G M A N"
  puts

  print_score correct_guesses

  puts ""
  puts ""
  puts "#{guesses_allowed} guesses left"
  puts "#{hints} hints left"
  puts
  print "What is your guess? (Enter '?' for a hint) "

end

def print_options options_hash
  options_hash.each do |k,v|
    puts k + ". " + v
  end
end

def clear_screen
  system("clear")
end

def main_menu
  response = nil
  options = {
    "1"     => "New Game",
    "2"     => "Log In",
    "3"     => "View Scores",
    "4"     => "Exit"
  }
  until options.include? response
    system("clear")
    puts "Welcome to Hangman\n\n"
    print_options options
    puts
    print "Select an option: "
    response = gets.chomp
  end
  return options[response]
end

def log_in_user
  print "Enter your name (Press enter to skip): "
  gets.chomp
end

def get_high_scores
  starting_score = 1000
  high_scores = []
  Game.all.each do |g|
    high_scores.push (
      [
        User.where(id: 1).pluck(:name).join,
        starting_score -
        g.tries_remaining -
        g.hints_remaining + g.hints_allowed +
        g.word.length - g.letters_guessed.length / 2 + 1
      ]
    )
  end
  high_scores.sort_by { |x,y| y }.reverse!
end

def view_scores
  puts "High Scores"
  scores = get_high_scores
  total_scores = (scores.count > 10 ? 9 : scores.count - 1)
  0.upto total_scores do |x|
    puts (x + 1).to_s + ". " + scores[x][0] + "\t\t\t" + scores[x][1].to_s
  end
  binding.pry
  puts "Press Enter to Return to Menu"
  gets
end


# Preliminary Stuff

min_word_length = 6
max_word_length = 10

valid_words = load_words("/usr/share/dict/words", min_word_length, max_word_length)
sorted_letters = get_letter_freq_ascending(valid_words)

# Main program

loop do
  case main_menu
  when "Exit"
    break
  when "Log In"
    username = log_in_user
  when "View Scores"
    view_scores
  when "New Game"
    puts "New Game Here"
  end
end

exit


game_on = true

while game_on

  guesses_allowed = 6
  hints = 3

  ## Select a word

  word = valid_words.sample.downcase.split("")
  correct_guesses = Array.new(word.count, "_")
  guess_list = []
  game_end = false
  win = false

  ## Start game

  until game_end

    print_screen(guesses_allowed, hints, correct_guesses)

    guess = gets.chomp.to_s.downcase

    if guess.downcase == word.join.downcase
      puts "What an amazing guess!"
      game_end = true
      win = true
      next

    elsif guess == "?"
      if hints > 0
        guess = get_hint(sorted_letters, correct_guesses, word, guess_list)
        hints -= 1
      else
        puts "You have no more hints!"
        sleep 1
        next
      end

    elsif guess_list.include? guess
      puts "You already guessed that."
      puts "Try again."
      sleep 1
      next

    elsif not allowed_chars.include? guess
      puts "That is not a valid character."
      sleep 1
      next

    else
      guess_list.push guess

    end

    if word.include? guess
      0.upto word.count - 1 do |x|
        if guess == word[x]
          correct_guesses[x] = guess
        end
      end
    else
      guesses_allowed -= 1
    end

    if correct_guesses == word
      game_end = true
      win = true
    end

    if guesses_allowed == 0
      game_end = true
    end
  end

  print_end_msg(word, win)

  if play_again?
    next
  else
    game_on = false
  end

end
