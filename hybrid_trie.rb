# Implementation of an Hybrid Trie
require "byebug"
require "#{Dir.pwd}/patricia_tree"
require "#{Dir.pwd}/helper"

class HybridTrie

  attr_accessor :value, :character, :inf_child, :eq_child, :sup_child

  EOW = 1.chr(Encoding::ASCII_8BIT)
  PRINT_EOW = '♥'
  BALANCED_ALPHA = 1

  def initialize(value = nil, character = '')
    @value = value
    @character = character
    @inf_child = nil
    @eq_child = nil
    @sup_child = nil
  end

  ##################
  ## Question 1.5 ##
  ##################

  #== Insertion ==#
  def insert(word, value = EOW)
    return self if word.empty?
    if word == EOW
      @value = word
      return self
    end

    # If we are in an empty trie we insert the word.
    if empty?
      if single_char?(word)
        flag_word(word, value)
      else
        @character = word[0]
        @eq_child = HybridTrie.new
        @eq_child = @eq_child.insert(rest(word), value)
      end
      return self
    end

    # Has the word been found?
    if @character == word
      flag_word(word, value) unless word?
      return self
    end

    first = first_letter(word)

    if first == @character
      @eq_child = HybridTrie.new if @eq_child.nil?
      @eq_child = @eq_child.insert(rest(word))
    end

    if greater_than?(first, @character)
      @sup_child = HybridTrie.new if @sup_child.nil?
      @sup_child = @sup_child.insert(word)
    end

    if less_than?(first, @character)
      @inf_child = HybridTrie.new if @inf_child.nil?
      @inf_child = @inf_child.insert(word)
    end
    self
  end

  ##################
  ## Question 2.6 ##
  ##################

  ## EQUIVALENT de Recherche(abre, mot) -> booléen ##
  # @return true if the word is in the trie, false otherwise
  # complexité : log3n
  def include?(word)
    return false if word.empty? || empty?

    # Is the word a single character?
    if single_char?(word)
      return true if word? && (word == @character)
      return @sup_child.nil? ? false : @sup_child.include?(word) if greater_than?(word, @character)
      return @inf_child.nil? ? false : @inf_child.include?(word) if less_than?(word, @character)
    end

    # -> The word is not a single character
    return word? && (word == @character) if leaf?

    # -> The trie has one or more child
    return @sup_child.nil? ? false : @sup_child.include?(word) if greater_than?(first_letter(word), @character)
    return @inf_child.nil? ? false : @inf_child.include?(word) if less_than?(first_letter(word), @character)

    # -> The first letter of the word equals the character
    @eq_child.include?(rest(word))
  end

  ## EQUIVALENT de ComptageMots(arbre) -> entier ##
  # @return the number of words in the dictionary
  # complexité : log3n
  def count_words
    return 0 if empty?
    return 1 if leaf?
    result = word? ? 1 : 0
    result += @inf_child.count_words unless @inf_child.nil?
    result += @sup_child.count_words unless @sup_child.nil?
    result += @eq_child.count_words unless @eq_child.nil?

    result
  end

  ## EQUIVALENT de ListeMots(arbre) -> liste[mots] ##
  # @return the list of words by alphabetical order
  def to_array(c_prefix = '')
    # If the tree is empty?
    return [] if empty?

    # The tree is not empty
    word = "#{c_prefix}#{@character}"

    words = []
    words += [word] if word?
    words += @inf_child.to_array(c_prefix) unless @inf_child.nil?
    words += @eq_child.to_array(word) unless @eq_child.nil?
    words += @sup_child.to_array(c_prefix) unless @sup_child.nil?

    words
  end

  ## EQUIVALENT de ComptageNil(arbre) -> entier ##
  # @return the number of nil pointers
  def count_nil_pointers
    result = 0
    result += @inf_child.nil? ? 1 : @inf_child.count_nil_pointers
    result += @sup_child.nil? ? 1 : @sup_child.count_nil_pointers
    result += @eq_child.nil? ? 1 : @eq_child.count_nil_pointers
  end

  ## EQUIVALENT de Hauteur(arbre) -> entier
  # @return the height of the trie
  def height(depth = 0)
    return 0 if empty?
    return depth + 1 if leaf?
    height_inf = @inf_child.nil? ? depth : @inf_child.height(depth+1)
    height_sup = @sup_child.nil? ? depth : @sup_child.height(depth+1)
    height_eq = @eq_child.nil? ? depth : @eq_child.height(depth+1)
    max([height_sup, height_inf, height_eq])
  end

  ## EQUIVALENT de ProfondeurMoyenne(arbre) -> entier
  # @return the average depth of the leaves
  def average_depth
    leaves = depth_leaves
    leaves.inject { |sum, el| sum + el } / leaves.size
  end

  # Helper function for the average_depth
  # @return the array of depth for each leaf of the trie
  def depth_leaves(depth = 0)
    return [] if empty?
    return [1 + depth] if leaf?

    depth += 1 # depth is now bigger
    result = []
    result += @inf_child.depth_leaves(depth) unless @inf_child.nil?
    result += @sup_child.depth_leaves(depth) unless @sup_child.nil?
    result += @eq_child.depth_leaves(depth) unless @eq_child.nil?
    result
  end

  ## EQUIVALENT de Prefixe(arbre, mot) -> entier
  # @return the number of word that have the following word as prefix
  def count_prefix(word)
    return 0 if empty?

    # We are counting the prefix, the word ended above
    if word.empty?
      return 1 if leaf?
      result = word? ? 1 : 0
      result += @inf_child.nil? ? 0 : @inf_child.count_prefix(word)
      result += @sup_child.nil? ? 0 : @sup_child.count_prefix(word)
      result += @eq_child.nil? ? 0 : @eq_child.count_prefix(word)
      return result
    end

    # The word is not empty
    if first_letter(word) == @character
      result = single_char?(word) ? 1 : 0
      @eq_child.nil? ? result : @eq_child.count_prefix(rest(word))
    elsif less_than?(first_letter(word), @character)
      @inf_child.nil? ? 0 : @inf_child.count_prefix(word)
    else
      @sup_child.nil? ? 0 : @sup_child.count_prefix(word)
    end
  end

  ## EQUIVALENT de Suppresion(abre, mot) -> arbre ##
  # @return the current trie with the given word deleted
  def delete(word)
    ## Base cases
    # end of the trie
    #  or
    # we found the end of the word
    return self if word.empty? || empty?

    if word == @character
      # We found the node marking the word
      # The node has no child -> return the empty trie
      return empty if leaf?

      # otherwise
      @value = nil
      return self unless @eq_child.nil?
      return @inf_child if @sup_child.nil? && !@inf_child.nil?
      return @sup_child if @inf_child.nil? && !@sup_child.nil?

      # Could be random
      @eq_child = @sup_child
      @sup_child = nil
      return self
    end

    ## Recursively
    # check the next letter on the children
    first = first_letter(word)

    if first == @character
      return self if @eq_child.nil?
      @eq_child = @eq_child.delete(rest(word))

      if @eq_child.empty?
        if !word? && @inf_child.nil? && @sup_child.nil?
          return empty
        else
          @eq_child = nil
        end
      end

    elsif greater_than?(first, @character)
      return self if @sup_child.nil?
      @sup_child = @sup_child.delete(word)
      @sup_child = nil if @sup_child.empty?

    elsif less_than?(first, @character)
      return self if @inf_child.nil?
      @inf_child = @inf_child.delete(word)
      @inf_child = nil if @inf_child.empty?
    end

    ## After the recursion
    return self if leaf? || (!@eq_child.nil? && !@eq_child.empty?)

    # We need to reorganize the trie as the current char is irrelevant to all

    # Easy cases
    if @sup_child.nil?
      replace(@inf_child) unless @inf_child.nil?
      return self
    elsif @inf_child.nil?
      replace(@sup_child) unless @sup_child.nil?
      return self
    end

    # Complex case, both child aren't nil
    # replace the center child by the most left trie from the sup child
    # and remove it.
    result = @sup_child.remove_most_left_child
    # self.sup_child has been updated

    @value = result.value
    @character = result.character
    @eq_child = result.eq_child
    self
  end

  ##################
  ## Question 3.8 ##
  ##################

  def to_patricia_tree
    #TODO
  end

  def to_patricia_tree_naive
    words = to_array
    new_tree = PatriciaTree.new
    words.each do |word|
      new_tree.insert(word)
    end
    new_tree
  end

  ##################
  ## Question 3.9 ##
  ##################

  def smart_insert(word, value = EOW)
    return self if word.empty?
    if word == EOW
      @value = word
      return self
    end

    if empty?
      if single_char?(word)
        flag_word(word, value)
      else
        @character = word[0]
        @eq_child = HybridTrie.new
        @eq_child = @eq_child.smart_insert(rest(word), value)
      end
      return self
    end

    # Has the word been found?
    if @character == word
      flag_word(word, value) unless word?
      return self
    end

    first = first_letter(word)

    if first == @character
      @eq_child = HybridTrie.new if @eq_child.nil?
      @eq_child = @eq_child.smart_insert(rest(word))
    end

    if greater_than?(first, @character)
      # Normal insertion as it's a new branch
      if @sup_child.nil?
        @sup_child = HybridTrie.new
        @sup_child = @sup_child.insert(word)
      else
        @sup_child = @sup_child.smart_insert(word)
        if @sup_child.sup_child.nil? && less_than?(first, @sup_child.character) &&
          @inf_child.nil?
          @sup_child.rotate_right
          self.rotate_left
        elsif @sup_child.inf_child.nil? && greater_than?(first, @sup_child.character) && @inf_child.nil?
          self.rotate_left
        end
      end
    end

    if less_than?(first, @character)
      # Normal insertion as it's a new branch
      if @inf_child.nil?
        @inf_child = HybridTrie.new
        @inf_child = @inf_child.insert(word)
      else
        @inf_child = @inf_child.smart_insert(word)
        if @inf_child.inf_child.nil? && greater_than?(first, @inf_child.character) && @sup_child.nil?
          @inf_child.rotate_left
          self.rotate_right
        elsif @inf_child.sup_child.nil? && less_than?(first, @inf_child.character) && @sup_child.nil?
          self.rotate_right
        end
      end
    end
    self
  end

  def balanced?
    return true if empty?

    inf_weight = @inf_child.nil? ? 0 : @inf_child.weight
    sup_weight = @sup_child.nil? ? 0 : @sup_child.weight
    result = sup_weight - inf_weight

    return false unless result <= BALANCED_ALPHA && result >= -BALANCED_ALPHA

    # Trie seems balanced at this level
    # recursive call to children
    result = true
    result &&= @inf_child.balanced? unless @inf_child.nil?
    result &&= @sup_child.balanced? unless @sup_child.nil?
    result &&= @eq_child.balanced? unless @eq_child.nil?
    result
  end

  def current_level_balanced?
    return true if empty?

    inf_weight = @inf_child.nil? ? 0 : @inf_child.weight
    sup_weight = @sup_child.nil? ? 0 : @sup_child.weight
    result = sup_weight - inf_weight

    result <= BALANCED_ALPHA && result >= -BALANCED_ALPHA
  end

  # Return the weight of the trie
  def weight
    return 0 if leaf? || empty?

    inf_weight = @inf_child.nil? ? 0 : 1 + @inf_child.weight
    sup_weight = @sup_child.nil? ? 0 : 1 + @sup_child.weight

    inf_weight + sup_weight
  end

  def rotate_left
    return if empty? || leaf? || @sup_child.nil?

    old_trie = clone
    inf_sup_child = @sup_child.inf_child
    replace(@sup_child)
    @inf_child = old_trie
    @inf_child.sup_child = inf_sup_child
  end

  def rotate_right
    return if empty? || leaf? || @inf_child.nil?

    old_trie = clone
    sup_inf_child = @inf_child.sup_child
    replace(@inf_child)
    @sup_child = old_trie
    @sup_child.inf_child = sup_inf_child
  end

  ##################
  ## Question 1.4 ##
  ##################

  # Return the leftest child and remove it from self
  def remove_most_left_child
    if leaf?
      leaf = clone
      empty
      return leaf
    end

    # We found the leftest trie
    if @inf_child.nil?
      left_child = clone
      left_child.sup_child = nil
      if @sup_child.nil?
        empty
      else
        replace(@sup_child)
      end

      return left_child
    end

    # Keep searching
    @inf_child.remove_most_left_child
  end

  # @return the number of nodes in the trie
  def size
    return 0 if empty?
    return 1 if leaf?
    result = 1
    result += @inf_child.size unless @inf_child.nil?
    result += @sup_child.size unless @sup_child.nil?
    result += @eq_child.size unless @eq_child.nil?
    result
  end

  # @return the first letter of the word
  def first_letter(word)
    word[0]
  end

  # @return the rest of the word except the first letter
  def rest(word)
    word.slice(1..word.size)
  end

  # @return true if the current word is simply a letter
  def single_char?(word)
    word.size == 1
  end

  # @return true if the current node is the end of a word
  def word?
    !@value.nil? && !@character.empty?
  end

  # Flag the current trie as a word
  def flag_word(word, value = EOW)
    @value = value
    @character = word
  end

  # Replace the current trie with the one specified
  def replace(trie)
    self.value = trie.value
    self.character = trie.character
    self.inf_child = trie.inf_child
    self.eq_child = trie.eq_child
    self.sup_child = trie.sup_child
  end

  # Clone the current trie.
  def clone
    new_clone = HybridTrie.new

    new_clone.value = @value
    new_clone.character = @character
    new_clone.inf_child = @inf_child
    new_clone.eq_child = @eq_child
    new_clone.sup_child = @sup_child

    new_clone
  end

  # @return true if the current node is a leaf (empty children)
  def leaf?
    !@value.nil? && !@character.empty? && @inf_child.nil? && @eq_child.nil? && @sup_child.nil?
  end

  # @return true if the current node is a empty
  def empty?
    @value.nil? && @character.empty? && @inf_child.nil? && @eq_child.nil? && @sup_child.nil?
  end

  # Empty the current trie.
  def empty
    @value = nil
    @character = ''
    @inf_child = nil
    @eq_child = nil
    @sup_child = nil
    self
  end

  #== Comparaison helpers ==#

  # @return true if value1 is greater than value2
  def greater_than?(value1, value2)
    value1 > value2
  end

  # @return true if value1 is less than value2
  def less_than?(value1, value2)
    value1 < value2
  end

  # @return the maximum of an array of values
  def max(values = [])
    return nil if values.empty?
    max_value = values[0]
    values.each do |value|
      max_value = value if value > max_value
    end
    max_value
  end

  # prints the trie for debug purposes
  def print_trie(depth = 0, prev = [' '])
    return print(".\n") if empty?

    print(".\n") if depth.zero?
    print("└── ") if depth == 0
    print("#{@character}")
    @value.nil? ? print("\n") : print(", #{PRINT_EOW}\n")
    print_depth_path(depth, prev)
    print("├── ")
    @inf_child.nil? ? print("\n") : @inf_child.print_trie(depth + 1, prev + ['│'])
    print_depth_path(depth, prev)
    print("├── ")
    @eq_child.nil? ? print("\n") : @eq_child.print_trie(depth + 1, prev + ['│'])
    print_depth_path(depth, prev)
    print("└── ")
    @sup_child.nil? ? print("\n") : @sup_child.print_trie(depth + 1, prev + [' '])
    true
  end

  def print_depth_path(depth, prev)
    (0..depth).each do |h|
      print("#{prev[h]}  ")
    end
  end

  # TESTS #

  def populate
    self.insert("hello")
    self.insert("hollymolly")
    self.insert("example")
    self.insert("exam")
    self.insert("zoopla")
    self.insert("helloopie")
    self.insert("hollymolly")
    self.insert("hell")
  end

  def populate_example
    ["A", "quel", "genial", "professeur", "de", "dactylographie", "sommes", "nous", "redevables", "de", "la", "superbe", "phrase", "ci", "dessous", "un", "modele", "du", "genre", "que", "toute", "dactylo", "connait", "par", "coeur", "puisque", "elle", "fait", "appel", "a", "chacune", "des", "touches", "du", "clavier", "de", "la", "machine", "a", "ecrire"].each do |word|
      insert(word)
    end
  end

  def populate_ordered(a = %w[a w b t c r d l])
    a.each do |w|
      smart_insert(w)
    end
  end

  def populate_with(a = %w[a w b t c r d l])
    a.each do |w|
      insert(w)
    end
  end
end
