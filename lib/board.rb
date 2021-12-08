# frozen_string_literal: true

# the mastermind game
class MastermindGame
  def play
    players = make_players
    code = players[:maker].make_code
    turns = 0
    loop do
      turns += 1
      guess = players[:breaker].make_guess
      break if guess == code

      hint = players[:maker].give_hint(guess, code)
      puts "#{hint[:correct]} numbers were correct, and #{hint[:included] - hint[:correct]} " \
          "numbers are in the code, but not in the correct position"
    end
    puts "#{players[:breaker].name} guessed the code in #{turns} turns!\n" \
          "code: #{code.join}"
  end

  private

  def make_players
    puts "Welcome to Mastermind!"
    puts "Would you like to be the code maker [M], or the code breaker [B]?"

    player_choice = ""
    loop do
      print '[M/B]:'
      player_choice = gets.chomp
      unless player_choice.match(/m|b/i)
        puts "Please choose 'M' or 'B'"
        next
      end
      break
    end

    case player_choice.capitalize
    when 'M'
      { maker: Player.new, breaker: Computer.new }
    when 'B'
      { maker: Computer.new, breaker: Player.new }
    end
  end
end

# player for mastermind game
class Player
  attr_reader :name

  def initialize
    @name = "The Player"
  end
  def make_code
    puts 'Choose a secret 4 number code, using the numbers 1-6.'
    code = ''
    loop do
      print ':'
      code = gets.chomp.delete(' ').split('')
      unless code.all? { |char| ('1'..'6').include?(char) }
        puts "please make sure that your code is only numbers between 1 and 6.\n\
          Example: 4 2 6 1"
        next
      end

      unless code.length == 4
        puts 'please enter 4 numbers'
        next
      end
      unless code.uniq.length == code.length
        puts 'make sure your code has no duplicates'
        next
      end

      break
    end
    code.map(&:to_i)
  end

  def make_guess
    puts "Guess the secret code"

    guess = ''
    loop do
      print ':'
      guess = gets.chomp
      unless guess.match?(/[1-6]{4}/)
        puts 'Invalid guess. The code must be 4 numbers long, with each number between 1 and 6'
        next
      end
      break
    end
    guess.split('').map(&:to_i)
  end

  def give_hint(guess, code)
    hint = { correct: 0, included: 0 }
    hint[:correct] = guess.reduce(0) do |memo, value|
      code.index(value) == guess.index(value) ? memo + 1 : memo
    end

    hint[:included] = guess.reduce(0) do |memo, value|
      code.include?(value) ? memo + 1 : memo
    end

    hint
  end
end

# AI for mastermind game
class Computer < Player
  def initialize
    @name = "The Mighty Machine"
  end

  def make_code
    (1..6).to_a.shuffle.take(4)
  end

  def make_guess
    # https://en.wikipedia.org/wiki/Mastermind_(board_game)#Worst_case:_Five-guess_algorithm
    make_code
  end
end
