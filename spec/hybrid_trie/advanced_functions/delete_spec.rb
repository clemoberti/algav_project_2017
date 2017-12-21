require '/home/clement/Uni/semestre_1/ALGAV/DM/hybrid_trie'

RSpec.describe "HybridTrie - Advanced" do
  describe "#delete" do

    before(:each) do
      @trie = HybridTrie.new
    end

    describe "when the word is not in the trie" do
      it do
        @trie.insert('toasted')
        @trie.delete('toas')
        expect(@trie.count_words).to eq(1)
      end
    end

    describe "when the word is in the trie" do
      it do
        @trie.insert('toast')
        @trie.delete('toast')
        expect(@trie.count_words).to eq(0)
        expect(@trie.to_array).to match_array([])
        expect(@trie.size).to eq(0)
      end

      it do
        words = %w[toast a b]
        words.each do |w|
          @trie.insert(w)
        end
        @trie.delete('toast')
        expect(@trie.count_words).to eq(2)
        expect(@trie.to_array).to match_array(%w[a b])
        expect(@trie.size).to eq(2)
      end

      it do
        words = %w[toaster toast toasted]
        words.each do |w|
          @trie.insert(w)
        end
        @trie.delete('toast')
        expect(@trie.count_words).to eq(2)
        expect(@trie.to_array).to match_array(%w[toasted toaster])
        expect(@trie.size).to eq(8)
      end

      it do
        words = %w[toasted toast toaster]
        words.each do |w|
          @trie.insert(w)
        end
        @trie.delete('toasted')
        @trie.print_trie
        puts @trie.inspect
        expect(@trie.count_words).to eq(2)
        expect(@trie.to_array).to match_array(%w[toast toaster])
        expect(@trie.size).to eq(7)
      end
    end

    describe "when the word is on the inf child" do
      it do
        words = %w[water igloo amour]
        words.each do |w|
          @trie.insert(w)
        end
        @trie.delete('igloo')
        expect(@trie.count_words).to eq(2)
        expect(@trie.to_array).to match_array(%w[amour water])
        expect(@trie.size).to eq(10)
      end
    end

    describe "when the word is on the sup child" do
      it do
        words = %w[amour igloo water]
        words.each do |w|
          @trie.insert(w)
        end
        @trie.delete('igloo')
        expect(@trie.count_words).to eq(2)
        expect(@trie.to_array).to match_array(%w[amour water])
        expect(@trie.size).to eq(10)
      end

      it do
        words = %w[amour igloo water]
        words.each do |w|
          @trie.insert(w)
        end
        @trie.delete('water')
        expect(@trie.count_words).to eq(2)
        expect(@trie.to_array).to match_array(%w[amour igloo])
        expect(@trie.size).to eq(10)
      end

      it do
        words = %w[amour igloo iglooton water]
        words.each do |w|
          @trie.insert(w)
        end
        @trie.delete('igloo')
        expect(@trie.count_words).to eq(3)
        expect(@trie.to_array).to match_array(%w[amour iglooton water])
        expect(@trie.size).to eq(18)
      end
    end
  end
end
