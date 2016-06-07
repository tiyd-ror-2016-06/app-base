class Game < ActiveRecord::Base
  def initialize(word:, tries_allowed:, tries_remaining:, hints_allowed:, hints_remaining:)
    super
    @word               = word
    @tries_allowed      = tries_allowed
    @tries_remaining    = tries_remaining
    @hints_allowed      = hints_allowed
    @hints_remaining    = hints_remaining
    @correct_guesses    = "_" * word.length
    @all_guesses        = []
  end

  def over?
    @tries_remaining == 0 || word_is_found?
  end

  def word_is_found?
    x = @word.split("").select { |letter| not @all_guesses.include? letter }
    x.empty?
  end

  def print_board(reveal_answers:)
    @word.split("").each do | letter |
      if reveal_answers || (@all_guesses.include? letter)
        print letter
      else
        print "_"
      end
      print " "
    end
    print "\n"
  end

  def print_status
    puts
    puts "#{@tries_remaining} guesses left"
    puts "#{@hints_remaining} left"
    puts
  end

  def print_options
    print "What is your guess? (Enter '?' for a hint; CTRL + C to quit)"
  end

  def prompt_user
    guess = gets.chomp.to_s.downcase
    if guess == @word
      amazing_guess
    elsif guess == "?"
      get_a_hint ||
        "You have no more hints!"
      sleep 1
    elsif @all_guesses.include? guess
      puts "You've already guessed that."
      sleep 1
    elsif not ("a".."z").include? guess
      puts "That is not a valid character."
      sleep 1
    else
      @all_guesses.push guess
      @tries_remaining -= 1
    end
  end

  def print_outcome
    if word_is_found?
      puts "Good job! You've won!"
    else
      puts "You've lost. Better luck next time..."
    end
  end

end


# def get_hint(sorted_letters, correct_guesses, word, guess_list)

#   # submit an hint that will reduce the remaining letters to guess by one

#   allowed_hints = sorted_letters - correct_guesses.uniq - guess_list.uniq
#   index = 0

#   until index == allowed_hints.length - 1
#     unless word.include? allowed_hints[index]
#       allowed_hints.delete_at(index)
#       next
#     else
#       index += 1
#     end
#   end

#   return allowed_hints[0]
# end
