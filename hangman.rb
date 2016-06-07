#  Hangman

require "pry"
require "./db/setup"
require "./lib/all"
require "./word_bank"

default_word_bank = "/usr/share/dict/words"

longstring = "asdasfdasdfad"

def less_for_ruby text
  IO.popen("less", "w") { |f| f.puts text }
end

#default_difficulty = :easy

game_options = {
    tries_allowed:      5,
    tries_remaining:    5,
    hints_allowed:      3,
    hints_remaining:    3,
}

wordbank_options = {
    min_word_length: 6,
    max_word_length: 10
}

def clear_screen
  system("clear")
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

def print_title #(guesses_allowed, hints, correct_guesses)
  clear_screen
  puts "H A N G M A N"
  puts
end

def print_options options_hash
  options_hash.each do |k,v|
    puts k + ". " + v
  end
end

def main_menu
  response = nil
  options = {
    "1"     => "New Game",
    "2"     => "View Scores",
    "3"     => "Exit"
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
  username = nil
  until (username =~ /\A[A-Za-z]+\z/ || username =~ /^$/)
    puts "Enter your name (Press enter to skip): "
    username = gets.chomp
  end
  username =~ /^$/ && username = "nobody"
  load_or_create_user username
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
  clear_screen
  puts "High Scores"
  puts
  scores = get_high_scores
  total_scores = (scores.count > 10 ? 9 : scores.count - 1)
  0.upto total_scores do |x|
    puts (x + 1).to_s + ". " + scores[x][0] + "\t\t\t" + scores[x][1].to_s
  end
  puts
  print "Press Enter to Return to Menu"
  gets
end

def new_game word_bank, game_options, user

  g = Game.new word: word_bank.sample, **(game_options)

  until g.over?
    print_title
    g.print_board   reveal_answers: false
    g.print_status
    g.print_options
    g.prompt_user
  end
  print_title
  g.print_board     reveal_answers: true
  g.print_outcome
  binding.pry
  g.save_game user.id
end

def load_or_create_user username
  unless u = User.where(name: username).first
    u = User.new
    u.name = username
    u.save
  end
  u
end

# Main program

loop do
  user ||= log_in_user
  case main_menu
  when "Exit"
    break
  when "View Scores"
    view_scores
  when "New Game"
    begin
      w = WordBank.new(
        source: default_word_bank, **(wordbank_options)
      )

      binding.pry
      new_game w, game_options, user

    rescue Interrupt
      puts "Returning to Main Menu..."
      sleep 1
      next
    end
  end
end

exit
