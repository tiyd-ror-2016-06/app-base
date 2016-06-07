class WordBank
  def initialize source:, min_word_length:, max_word_length:
    @source = source
    @min = min_word_length
    @max = max_word_length
    @valid_words = load_words
    @letter_frequencies = nil
  end

  def load_words
    STDERR.print "Loading words ...\n"
    words = File.open(@source, "r").map  { |x| x.chomp }.select do |line|
      line.length <= @max && line.length >= @min
    end
    return words
  end

  def sample
    @valid_words.sample
  end

  def letter_frequencies
    unless @letter_frequencies
      @letter_frequencies = get_letter_freq_ascending
    end
    @letter_frequencies
  end

  def get_letter_freq_ascending

    # returns a hash with frequency of each letter in ascending order
      h = ("a".."z").map { |x| [x,0] }.to_h

      @valid_words.each do |item|
        item.split("").each do |letter|
          letter.downcase!
          h.include? letter && h[letter] += 1
        end
      end

      h = h.sort_by { |a, b| b } # .map { |a,b| a }
      h.map { |a,b| a }
  end
end
