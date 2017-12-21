require '/home/clement/Uni/semestre_1/ALGAV/DM/patricia_tree'

RSpec.describe "PatriciaTree" do
  describe "#merge" do

    before(:each) do
      @trie = PatriciaTree.new
    end

    describe "we merge a cloned tree" do
      it do
        h2 = PatriciaTree.new
        h = PatriciaTree.new
        HelperTrie.new.read_file('1henryvi.txt', h2)
        HelperTrie.new.read_file('1henryvi.txt', h)
        h.merge(h2)

        expect(h.count_words).to eq(h2.count_words)
      end
    end

    describe "we merge two small trees" do
      it do
        h = PatriciaTree.new
        h2 = PatriciaTree.new
        h3 = PatriciaTree.new
        h4 = PatriciaTree.new

        ["A", "quel", "genial", "professeur", "de", "dactylographie", "sommes", "nous", "redevables"].each do |word|
          h.insert(word)
          h4.insert(word)
        end

        ["de", "la", "superbe", "phrase", "ci", "dessous", "un", "modele", "du", "genre", "que", "toute", "dactylo", "connait", "par", "coeur", "puisque", "elle", "fait", "appel", "a", "chacune", "des", "touches", "du", "clavier", "de", "la", "machine", "a", "ecrire"].each do |word|
          h2.insert(word)
        end
        h.merge(h2)
        h2.merge(h4)

        ["A", "quel", "genial", "professeur", "de", "dactylographie", "sommes", "nous", "redevables", "de", "la", "superbe", "phrase", "ci", "dessous", "un", "modele", "du", "genre", "que", "toute", "dactylo", "connait", "par", "coeur", "puisque", "elle", "fait", "appel", "a", "chacune", "des", "touches", "du", "clavier", "de", "la", "machine", "a", "ecrire"].each do |word|
          h3.insert(word)
        end

        expect(h.count_words).to eq(h3.count_words)
        expect(h.count_words).to eq(h2.count_words)
      end
    end

    describe "we merge two small trees" do
      it do
        h = PatriciaTree.new
        h2 = PatriciaTree.new
        result = ["thunder", "thunders", "thunderbolt"]

        ["thunder", "thunders"].each do |word|
          h.insert(word)
        end

        ["thunderbolt"].each do |word|
          h2.insert(word)
        end
        h.merge(h2)

        expect(h.count_words).to eq(result.size)
        expect(h.to_array).to match_array(result)
      end
    end

    describe "we merge two small trees" do
      it do
        h = PatriciaTree.new
        h2 = PatriciaTree.new
        h3 = PatriciaTree.new

        a1 = ["than", "thank", "thanked", "thanks", "thans", "that", "the", "thee", "theft", "their", "them", "the...", "thrusting", "thumb", "thunder", "thunderbolt", "thunders", "thursday", "thus", "thy", "thyself"]
        a2 = ["than", "thank", "thanked", "thanks", "that", "the", "thee", "theft", "their", "them", "theme", "the...hrows", "thrust", "thrusting", "thumb", "thunder", "thunders", "thursday", "thus", "thy", "thyself"]

        a1.each do |word|
          h.insert(word)
          h3.insert(word)
        end

        a2.each do |word|
          h2.insert(word)
        end
        h.merge(h2)

        expect(h.count_words).to eq((a1 | a2).size)
        expect(h.to_array).to match_array(a1 | a2)
      end
    end
  end
end
