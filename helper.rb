require 'benchmark'

class HelperTrie

  def read_all_shakespeare
    result = []
    Dir["#{Dir.pwd}/shakespeare/*"].each do |book|
      File.read(book).each_line do |line|
        result.push(line.chomp)
      end
    end
    result
  end

  def insert_all_shakespeare(tree_name)
    tree = case tree_name
           when "hybrid"
             HybridTrie.new
           when "patricia"
             PatriciaTree.new
           end
    Dir["#{Dir.pwd}/shakespeare/*"].each do |book|
      File.read(book).each_line do |line|
        tree.insert(line.chomp)
      end
    end
    tree
  end

  def read_file(file_name, tree)
    File.read("#{Dir.pwd}/shakespeare/#{file_name}").each_line do |line|
      tree.insert(line.chomp)
    end
    true
  end

  def measure(tree_name)
    words = read_all_shakespeare

    tree = case tree_name
           when "hybrid"
             HybridTrie.new
           when "patricia"
             PatriciaTree.new
           end

    Benchmark.bm do |x|
      x.report { words.each { |w| tree.insert(w) } }
    end
    true
  end

  def measure_deletion(tree_name)
    tree = case tree_name
           when "hybrid"
             HybridTrie.new
           when "patricia"
             PatriciaTree.new
           end
    words = read_all_shakespeare

    words.each { |w| tree.insert(w) }

    Benchmark.bm do |x|
      (0..20).each do
        tree = case tree_name
               when "hybrid"
                 HybridTrie.new
               when "patricia"
                 PatriciaTree.new
               end
        words.each { |w| tree.insert(w) }
        x.report { words.each { |w| tree.delete(w) } }
      end
    end
    true
  end
end
