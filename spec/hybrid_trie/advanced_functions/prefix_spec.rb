require '/home/clement/Uni/semestre_1/ALGAV/DM/hybrid_trie'

RSpec.describe "HybridTrie - Advanced" do
  describe "#prefix" do

    before(:each) do
      @trie = HybridTrie.new
    end

    describe "when there are 3 words with prefix 'toas'" do
      it do
        words = %w[toast toaster toasted camomille]
        words.each do |w|
          @trie.insert(w)
        end
        expect(@trie.count_prefix('toas')).to eq(3)
      end
    end

    describe "when there is 1 word with prefix 't'" do
      it do
        words = %w[toast atterir mat]
        words.each do |w|
          @trie.insert(w)
        end
        expect(@trie.count_prefix('t')).to eq(1)
      end
    end

    describe "when there are no words with prefix 'toas'" do
      it do
        words = %w[rognon mystère camomille]
        words.each do |w|
          @trie.insert(w)
        end
        expect(@trie.count_prefix('toas')).to eq(0)
      end
    end
  end
end
