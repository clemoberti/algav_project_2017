require '/home/clement/Uni/semestre_1/ALGAV/DM/hybrid_trie'

RSpec.describe "HybridTrie - Basic" do
  describe "#leaf?" do

    before(:each) do
      @trie = HybridTrie.new
    end

    describe "when it's not a leaf" do
      it { expect(@trie.leaf?).to be false }
      it do
        @trie.insert("word")
        expect(@trie.leaf?).to be false
      end
    end

    describe "when it's a leaf" do
      before(:each) do
        @trie.empty
      end

      it do
        @trie.insert("w")
        expect(@trie.leaf?).to be true
      end

      it do
        @trie.insert("to")
        expect(@trie.eq_child.leaf?).to be true
      end
    end
  end

  describe "#empty?" do

    before(:each) do
      @trie = HybridTrie.new
    end

    describe "when it's empty" do
      it { expect(@trie.empty?).to be true }
      it do
        @trie.insert("word")
        @trie.empty
        expect(@trie.empty?).to be true
      end
    end

    describe "when it's not empty" do
      it do
        @trie.insert("w")
        expect(@trie.empty?).to be false
      end
    end
  end

  describe "#word?" do

    before(:each) do
      @trie = HybridTrie.new
    end

    describe "when it's a word" do
      it do
        @trie.insert('w')
        expect(@trie.word?).to be true
      end

      it do
        @trie.empty
        @trie.insert("he")
        @trie.insert("a")
        expect(@trie.eq_child.word?).to be true
        expect(@trie.inf_child.word?).to be true
      end
    end

    describe "when it's not a word" do
      it do
        @trie.insert('hello')
        expect(@trie.word?).to be false
      end

      it do
        @trie.empty
        @trie.insert('gogogo')
        @trie.insert('water')
        expect(@trie.eq_child.word?).to be false
        expect(@trie.sup_child.word?).to be false
      end
    end
  end

  describe "#count_words" do

    before(:each) do
      @trie = HybridTrie.new
    end

    describe "when there is 1 word" do
      it do
        words = %w[water]
        words.each do |w|
          @trie.insert(w)
        end
        expect(@trie.count_words).to eq(1)
      end
    end

    describe "when there are 2 words" do
      it do
        words = %w[water watering]
        words.each do |w|
          @trie.insert(w)
        end
        expect(@trie.count_words).to eq(2)
      end
    end

    describe "when there are 6 words" do
      it do
        words = %w[water watering toast toaster toasting toasted]
        words.each do |w|
          @trie.insert(w)
        end
        expect(@trie.count_words).to eq(6)
      end
    end

    describe "when there are no words" do
      it { expect(@trie.count_words).to eq(0) }
    end
  end
end
