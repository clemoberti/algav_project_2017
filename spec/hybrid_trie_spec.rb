require '/home/clement/Uni/semestre_1/ALGAV/DM/hybrid_trie'

RSpec.describe "HybridTrie" do
  describe "#size" do

    before(:each) do
      @trie = HybridTrie.new
    end

    describe "when there is 5 nodes" do
      it do
        words = %w[water]
        words.each do |w|
          @trie.insert(w)
        end
        expect(@trie.size).to eq(5)
      end
    end

    describe "when there are 8 nodes" do
      it do
        words = %w[water watering]
        words.each do |w|
          @trie.insert(w)
        end
        expect(@trie.size).to eq(8)
      end
    end

    describe "when there are 19 nodes" do
      it do
        words = %w[water watering toast toaster toasting toasted]
        words.each do |w|
          @trie.insert(w)
        end
        expect(@trie.size).to eq(19)
      end
    end

    describe "when there are no nodes" do
      it { expect(@trie.size).to eq(0) }
    end
  end

  describe "#single_char?" do
    describe "when there is one character" do
      it { expect(HybridTrie.new.single_char?("h")).to be true }
      it { expect(HybridTrie.new.single_char?("5")).to be true }
      it { expect(HybridTrie.new.single_char?("!")).to be true }
    end

    describe "when there is no character" do
      it { expect(HybridTrie.new.single_char?("")).to be false }
    end

    describe "when there are many characters" do
      it { expect(HybridTrie.new.single_char?("two")).to be false }
      it { expect(HybridTrie.new.single_char?("three")).to be false }
    end
  end
end
