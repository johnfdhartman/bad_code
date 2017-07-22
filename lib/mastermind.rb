
class Code
  attr_reader :pegs

  PEGS = Hash[['r','b','g','o','p','y'].zip [0]*6]


  def initialize(pegs)
    #pegs stored as an array of four symbols, one for each colour
    @pegs = pegs
  end

  def compare(other_code)
    matched_1= @pegs.zip [false,false,false,false]
    matched_2 = other_code.pegs.zip [false,false,false,false]
    exact, matched_1, matched_2 = exact_pairs(matched_1, matched_2)
    near = near_pairs(matched_1, matched_2)[0]
    {:near => near, :exact => exact}
  end

  def exact_pairs(matched_1, matched_2)
    exact_count = 0
    matched_1.each.with_index do |peg_1, idx|
      if peg_1 == matched_2[idx]
        peg_1[1], matched_2[idx][1] = true, true
        exact_count +=1
      end
    end
    [exact_count, matched_1, matched_2]
  end

  def near_pairs(matched_1, matched_2)
    near_count = 0
    matched_1.each do |peg_1|
      matched_2.each do |peg_2|
        if peg_1[0] == peg_2[0] && !peg_1[1] && !peg_2[1]
          near_count += 1
          peg_1[1], peg_2[1] = true, true
        end
      end
    end
    [near_count, matched_1, matched_2]
  end

  def exact_matches(other_code)
    self.compare(other_code)[:exact]
  end

  def near_matches(other_code)
    self.compare(other_code)[:near]
  end

  def self.parse(peg_string)
    peg_string.downcase!
    raise "invalid string" unless Code.valid_string?(peg_string)
    pegs = peg_string.downcase.split('').map {|char| char.to_sym}
    Code.new(pegs)
  end

  def self.random
    permutations = PEGS.keys.repeated_permutation(4).to_a
    Code.new(permutations.sample.join)
  end

  def self.valid_string?(peg_string)
    passed = true
    peg_string.chars do |char|
      unless PEGS.keys.include?(char)
        raise "peg_string = #{peg_string}"
        passed = false
      end
    end
    passed
  end

  def [](index)
    @pegs[index]
  end

  def ==(other_object)
    if other_object.class == Code
      return true if other_object.pegs == @pegs
    end
    false
  end

end

class Game
  attr_reader :secret_code
  def initialize(code = false)
    @turns_passed = 0
    if code
      @secret_code = code
    else
      @secret_code = Code.random
    end
  end

  def get_guess()
    puts "Guess a code"
    guess_str = gets.downcase.chomp
    p guess_str
    Code.parse(guess_str)
  end

  def take_turn()
    p @secret_code
    guess = self.user_guess
    matches = guess.compare(@secret_code)
    puts "Near matches: #{matches[:near]}\n
    Exact_matches: #{matches[:exact]}"
    @turns_passed += 1
    puts "#{10 - @turns_passed} turns left."
    matches
  end

  def play_loop()
    correct = false
    until correct || @turns_passed >= 12
      if self.take_turn[:exact] >= 4
        correct = true
      end
    end
    if correct == true
      puts "You're winner!!!"
    else
      puts "Try again!"
    end
  end
end
