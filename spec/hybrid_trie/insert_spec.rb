require '/home/clement/Uni/semestre_1/ALGAV/DM/hybrid_trie'

RSpec.describe "HybridTrie" do
  describe "#insert" do

    before(:each) do
      @trie = HybridTrie.new
    end

    describe "for one word" do
      context "before insertion" do
        it do
          expect(@trie.to_array).to be_empty
          expect(@trie.count_words).to eq(0)
        end
      end

      context "after insertion" do
        it do
          @trie.insert('manger')
          expect(@trie.to_array).to match_array(['manger'])
          expect(@trie.count_words).to eq(1)
        end
      end
    end

    describe "for duplicates" do
      before(:each) do
        @trie.insert('manger')
      end

      context "before insertion" do
        it do
          expect(@trie.to_array).to match_array(['manger'])
          expect(@trie.count_words).to eq(1)
        end
      end

      context "after insertion" do
        it do
          @trie.insert('manger')
          expect(@trie.to_array).to match_array(['manger'])
          expect(@trie.count_words).to eq(1)
        end
      end
    end

    describe "for words with the prefix already inserted " do
      before(:each) do
        @trie.insert('toast')
      end

      context "before insertion" do
        it do
          expect(@trie.include?('toast')).to be true
        end
      end

      context "after insertion" do
        it do
          @trie.insert('toasted')
          expect(@trie.to_array).to match_array(%w[toast toasted])
          expect(@trie.include?('toast')).to be true
          expect(@trie.include?('toasted')).to be true
        end
      end
    end
  end
end
