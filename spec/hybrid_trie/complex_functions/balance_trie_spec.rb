require '/home/clement/Uni/semestre_1/ALGAV/DM/hybrid_trie'

RSpec.describe "HybridTrie - Complex" do
  describe "#balance_trie" do
  end

  describe "#balanced?" do

    before(:each) do
      @trie = HybridTrie.new
    end

    describe "when it's a balanced trie" do
      it { expect(@trie.balanced?).to be true }

      it do
        @trie.insert('ramon')
        expect(@trie.balanced?).to be true
      end

      it do
        words = %w[crocodile bravo ami dandee equivalence]
        words.each do |w|
          @trie.insert(w)
        end
        expect(@trie.balanced?).to be true
      end

      it do
        words = %w[toast toasted toaster toasting]
        words.each do |w|
          @trie.insert(w)
        end
        expect(@trie.balanced?).to be true
      end

      it do
        words = %w[toast toasted toaster toasting harvest ameliorer]
        words.each do |w|
          @trie.insert(w)
        end
        expect(@trie.balanced?).to be true
      end

      it do
        @trie.populate_with(%w[l b a c y x y z w])
        expect(@trie.balanced?).to be true
      end
    end

    describe "when it's not a balanced trie" do
      it do
        words = %w[ami bravo crocodile dandee equivalence fatigue]
        words.each do |w|
          @trie.insert(w)
        end
        expect(@trie.balanced?).to be false
      end

      it do
        words = %w[fatigue equivalence dandee crocodile ami bravo]
        words.each do |w|
          @trie.insert(w)
        end
        expect(@trie.balanced?).to be false
      end

      it do
        @trie.populate_with(%w[a w b x c])
        expect(@trie.balanced?).to be false
      end

      it do
        @trie.populate_with(%w[l a b c d z y x w])
        expect(@trie.balanced?).to be false
      end

      it do
        @trie.populate_with(%w[l d c b a w x y z])
        expect(@trie.balanced?).to be false
      end

      it do
        @trie.populate_with(%w[l b a c w x y z])
        expect(@trie.balanced?).to be false
      end

      it do
        @trie.populate_with(%w[l a e b d c z v y w x])
        expect(@trie.balanced?).to be false
      end
    end
  end
end
