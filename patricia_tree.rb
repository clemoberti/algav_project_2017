# coding: utf-8
require "byebug"
require "#{Dir.pwd}/hybrid_trie"
require "#{Dir.pwd}/helper"

class PatriciaTree
  
  attr_accessor :children
  EOW = 1.chr(Encoding::ASCII_8BIT)
  PRINT_EOW = '♥'
  
  # Initialize the Patricia Tree
  def initialize
    # Hash of Patricia trees and labels,
    # The key is the first member of the node's edge sequence
    # eg: {'e' => { label: 'ed', tree: PatriciaTree },
    #      'i' => { label: 'ing', tree: PatriciaTree }}
    @children = {}
  end

  ##################
  ## Question 1.3 ##
  ##################

  # Insert a new word to the tree
  def insert(word)
    # If the tree OR the word is empty OR no common letter
    return flag_as_word(word) if empty_tree? || word == '' || @children[word[0]].nil?

    # Tree and word are not empty
    #   and
    # The first letter is already there
    child_tree = @children[word[0]][:tree]
    c_label = common_label(word)
    if word == c_label
      child_tree.insert('') unless child_tree.nil? # The word is already there
      return
    end

    # The word diverge from the existing branches
    return fork_child(word, common_sub_label(word)) if c_label.empty?

    suffix = suffix(word, c_label)
    # There are no descendant as its the end of a word
    # we need to create a new Patricia tree for it
    if child_tree.nil?
      new_tree = PatriciaTree.new # The new tree will be the end of the existing word
      new_tree.add_child(EOW)
      new_tree.flag_as_word(suffix)
      @children[word[0]][:tree] = new_tree
      return
    end

    child_tree.insert(suffix)
  end

  ##################
  ## Question 2.6 ##
  ##################

  # Equivalent of a search function
  # @return true if the tree includes the word
  def include?(word)
    return false if empty_tree? || @children[word[0]].nil?
    return word? if word.empty?
    return true if @children[word[0]][:label] == word && @children[word[0]][:tree].nil?

    # Find substring in common (if any)
    c_label = common_label(word)
    return false if c_label.empty?

    # Check in the children
    @children[word[0]][:tree].include?(suffix(word, c_label))
  end

  ## EQUIVALENT de ComptageMots(abre) -> entier ##
  # @return the number of words in the dictionary
  def count_words
    to_array.size
  end

  ## EQUIVALENT de ListeMots(abre) -> liste[mots] ##
  # @return the list of words by alphabetical order
  def to_array(prefix = '')
    result = []
    result.push(prefix) if word?
    @children.each_key do |child|
      label = @children[child][:label]
      label = '' if label == EOW
      new_prefix = "#{prefix}#{label}"

      if @children[child][:tree].nil?
        result.push(new_prefix)
      else
        result |= @children[child][:tree].to_array(new_prefix)
      end
    end
    result
  end

  ## EQUIVALENT de ComptageNil(arbre) -> entier ##
  # @return the number of nil pointers
  def count_nil_pointers
    return 0 if empty_tree?

    result = 0
    @children.each_key do |k|
      result += @children[k][:tree].nil? ? 1 : @children[k][:tree].count_nil_pointers
    end
    result
  end

  ## EQUIVALENT de Hauteur(arbre) -> entier
  # @return the height of the trie
  def height(depth = 0)
    return 0 if empty_tree?
    max = depth

    @children.each_key do |k|
      height_child = @children[k][:tree].nil? ? depth + 1 : @children[k][:tree].height(depth + 1)
      max = height_child if max < height_child
    end
    max
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
    return [] if empty_tree?
    return [1 + depth] if leaf?

    result = []

    @children.each_key do |k|
      result += @children[k][:tree].depth_leaves(depth + 1) unless @children[k][:tree].nil?
    end
    result
  end

  ## EQUIVALENT de Prefixe(arbre, mot) -> entier
  # @return the number of word that have the following word as prefix
  def count_prefix(word)
    return 0 if empty_tree? || word.include?(EOW)

    # We've reached the point where we can start counting
    if word.empty?
      counter = 0
      @children.each_key do |k|
        counter += @children[k][:tree] ? @children[k][:tree].count_prefix('') : 1
      end
      return counter
    end

    # the word is not empty look in the children
    return 0 if @children[word[0]].nil?

    label = @children[word[0]][:label]
    c_prefix = common_prefix(word, label)

    if c_prefix == word
      @children[word[0]][:tree] ? @children[word[0]][:tree].count_prefix('') : 1
    elsif c_prefix == label
      @children[word[0]][:tree] ? @children[word[0]][:tree].count_prefix(suffix(word, c_prefix)) : 0
    else
      0
    end
  end

  ## EQUIVALENT de Suppresion(abre, mot) -> arbre ##
  # @return the current trie with the given word deleted
  def delete(word)
    # Tree is empty
    return if empty_tree?

    # We recursively called delete and found the word
    return remove_child(word) if word.empty?

    # Word is not in the tree
    return if
      @children[word[0]].nil? ||
      common_prefix(word, @children[word[0]][:label]) != @children[word[0]][:label] ||
      (!suffix(word, @children[word[0]][:label]).empty? && @children[word[0]][:tree].nil?)

    # Word is in the tree
    # Remove or call recursively
    if @children[word[0]][:tree].nil?
      remove_child(word)
    else
      @children[word[0]][:tree].delete(suffix(word, @children[word[0]][:label]))
      if @children[word[0]][:tree].singleton?
        child = @children[word[0]][:tree].first_child
        if child[:label] == EOW
          @children[word[0]][:tree] = nil
          return
        end

        # The only child is not an End Of Word
        @children[word[0]][:label] += child[:label]
        @children[word[0]][:tree] = child[:tree]
        return
      end
    end
  end

  ##################
  ## Question 3.7 ##
  ##################

  def merge(tree)
    return if tree.nil? || tree.empty_tree?

    # There are elements in the trie
    tree.children.each_key do |k|
      if @children[k].nil?
        # The letter does not exist
        # -> add a new child
        @children[k] = tree.children[k]
        next
      elsif @children[k][:label] == tree.children[k][:label]
        # The same label is in both trees
        # -> merge recursively
        if @children[k][:tree].nil?
          next if tree.children[k][:tree].nil?
          tree.children[k][:tree].add_child(EOW)
          @children[k][:tree] = tree.children[k][:tree]
        else
          @children[k][:tree].merge(tree.children[k][:tree])
        end
        next
      end

      c_prefix = common_prefix(@children[k][:label], tree.children[k][:label])

      # Parts of the label is in both trees
      if c_prefix == tree.children[k][:label]
        # Eg: tomato + tom -> c_prefix = tom
        suffix = suffix(@children[k][:label], c_prefix)

        @children[k][:label] = c_prefix

        if tree.children[k][:tree].nil?
          new_tree = PatriciaTree.new
          new_tree.add_child(suffix, @children[k][:tree])
          new_tree.merge(tree.children[k][:tree]) unless tree.children[k][:tree].nil?
          @children[k][:tree] = new_tree
          @children[k][:tree].add_child(EOW)
        else
          if @children[k][:tree].nil?
            @children[k][:tree] = PatriciaTree.new
            @children[k][:tree].add_child(EOW)
          end
          @children[k][:tree].merge(tree.children[k][:tree])
        end
      elsif c_prefix == @children[k][:label]
        # Eg: tom + tomato -> c_prefix = tom
        tree.children[k][:label] = suffix(tree.children[k][:label], c_prefix)

        if @children[k][:tree].nil?
          @children[k][:tree] = PatriciaTree.new
          @children[k][:tree].add_child(EOW)
        end
        new_tree = PatriciaTree.new
        new_tree.add_child(tree.children[k][:label], tree.children[k][:tree])
        @children[k][:tree].merge(new_tree)
      else
        # Split the tree
        # toast && tomato
        # -> {to} PatriciaTree {ast ; mato}
        tree.children[k][:label] = suffix(tree.children[k][:label], c_prefix)
        suffix = suffix(@children[k][:label], c_prefix)

        new_tree = PatriciaTree.new
        new_tree.add_children([[suffix, @children[k][:tree]], [tree.children[k][:label], tree.children[k][:tree]]])

        @children[k][:label] = c_prefix
        @children[k][:tree] = new_tree
      end
    end
    true
  end

  def merge_naive(tree)
    tree.to_array.each do |word|
      insert(word)
    end
    true
  end

  ##################
  ## Question 3.8 ##
  ##################

  def to_hybrid_trie
    return HybridTrie.new if empty_tree?

    index = 0
    @children.each_key do |key|
      if key == EOW
        # TODO
      end
    end
  end

  def to_hybrid_trie_naive
    words = to_array
    new_trie = HybridTrie.new
    words.each do |word|
      new_trie.insert(word)
    end
    new_trie
  end

  ##################
  ## Question 1.4 ##
  ##################

  # Print the Patricia Tree (debug purposes)
  def print_tree(depth = 0, prev = [])
    print(".\n") if depth.zero?

    index = 0

    @children.each_key do |key|
      if depth > 0
        (0..depth-1).each do |h|
          print("#{prev[h]}  ")
        end
      end

      index == @children.size - 1 ? print('└') : print('├')

      if @children[key][:tree].nil?
        label = @children[key][:label]
        label = PRINT_EOW if label == EOW
        print("── #{label}")
        print(", #{PRINT_EOW}") if @children[key][:label] != EOW
        print("\n")
      else
        print("── #{@children[key][:label]}\n")

        s = index == @children.size - 1 ? ' ' : '│'

        @children[key][:tree].print_tree(depth + 1, prev + [s])
      end
      index += 1
    end
    "Tadaaaaa"
  end

  def fork_child(word, sub_label)
    raise(StandardError, "sub_label must be different than ''") if sub_label.empty?
    child = @children[word[0]]
    label_suffix = suffix(child[:label], sub_label)
    word_suffix = suffix(word, sub_label)

    # We have no other sub trees to take care of
    if child[:tree].nil?
      new_tree = PatriciaTree.new
      new_tree.insert(label_suffix)
      new_tree.insert(word_suffix)
      child[:tree] = new_tree
      child[:label] = sub_label
      return
    end

    word_suffix ||= EOW
    new_tree = PatriciaTree.new
    new_tree.add_children([[label_suffix, child[:tree]], [word_suffix]])
    child[:tree] = new_tree
    child[:label] = sub_label
  end

  # Add multiple children to the patricia tree
  def add_children(children)
    children.each do |c|
      add_child(c[0], c[1])
    end
  end

  # Add a patricia tree child of the current tree
  def add_child(word, tree = nil)
    @children[word[0]] = { label: word, tree: tree }
    # @children = @children.sort.to_h
  end

  # Add a patricia tree child of the current tree
  def remove_child(word)
    return @children.delete(EOW) if word.empty?
    return @children.delete(word[0]) if @children[word[0]][:label] == word
    raise(Exception, "error")
  end

  def first_child
    @children[@children.keys[0]]
  end

  # @return true if it's a leaf, false otherwise
  def leaf?
    result = true
    @children.each_key do |k|
      result &&= @children[k][:tree].nil?
    end
    result
  end

  def singleton?
    @children.size == 1
  end

  # @return true if it's an empty tree, false otherwise
  def empty_tree?
    @children.empty?
  end

  # @return true if the current Patricia Tree is a complete word
  def word?
    !@children[EOW].nil?
  end

  # We want to insert the word in the current Patricia Tree
  def flag_as_word(word = nil)
    raise(StandardError, 'nil word cannot be flagged') if word.nil?

    # No common letter
    return add_child(word) if @children[word[0]].nil? && !word.empty?

    # The word is ending in the current tree
    add_child(EOW)
  end

  # This function returns the label
  # in common with the given word.
  def common_label(word)
    return '' if word.empty?

    child = @children[word[0]]
    return '' if child.nil?

    child[:label].each_char.with_index do |c, i|
      return '' if c != word[i]
    end

    child[:label]
  end

  # Return the common sub-label of the word
  def common_sub_label(word)
    child = @children[word[0]]
    return '' if child.nil?

    word.each_char.with_index do |c, i|
      return word[0...i] if c != child[:label][i]
    end

    word
  end

  def common_prefix(word1, word2)
    return '' if word1[0] != word2[0]

    word1.each_char.with_index do |c, i|
      return word1[0...i] if c != word2[i]
    end
    word1
  end
  
  def suffix(word, prefix)
    prefix.each_char.with_index do |letter, index|
      return word if word[index] != letter
    end
    word.sub(prefix, '')
  end
  
  # TESTS

  def populate
    ["A", "quel", "genial", "professeur", "de", "dactylographie", "sommes", "nous", "redevables", "de", "la", "superbe", "phrase", "ci", "dessous", "un", "modele", "du", "genre", "que", "toute", "dactylo", "connait", "par", "coeur", "puisque", "elle", "fait", "appel", "a", "chacune", "des", "touches", "du", "clavier", "de", "la", "machine", "a", "ecrire"].each do |word|
      insert(word)
    end
  end

  def populate2
    %w[arbre bouchon ramon clement clem clementine clemence].each do |word|
      insert(word)
    end
  end
end
