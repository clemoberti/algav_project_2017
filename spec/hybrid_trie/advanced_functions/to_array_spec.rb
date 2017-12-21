require '/home/clement/Uni/semestre_1/ALGAV/DM/hybrid_trie'

RSpec.describe "HybridTrie - Advanced" do
  describe "#to_array" do

    before(:each) do
      @trie = HybridTrie.new
    end

    describe "when it's an empty trie" do
      it { expect(@trie.to_array).to be_empty }
    end

    describe "when it's a two words trie" do
      before(:each) do
        @trie.empty
      end

      it do
        @trie.insert("word")
        @trie.insert("wording")
        expect(@trie.to_array).to match_array(%w[word wording])
      end

      it do
        @trie.insert("toast")
        @trie.insert("toaster")
        @trie.insert("toasted")
        expect(@trie.to_array).to match_array(%w[toast toasted toaster])
      end

      it do
        @trie.insert("biche")
        @trie.insert("wagon")
        @trie.insert("miaou")
        @trie.insert("arbre")
        expect(@trie.to_array).to match_array(%w[arbre biche miaou wagon])
      end
    end
  end
end
