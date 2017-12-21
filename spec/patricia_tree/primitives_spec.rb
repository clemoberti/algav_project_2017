require '/home/clement/Uni/semestre_1/ALGAV/DM/patricia_tree'

RSpec.describe "PatriciaTree" do
  describe "#common_label" do

    before(:each) do
      @tree = PatriciaTree.new
    end

    describe "when there is a common label" do
      it do
        @tree.children = { "t" => {label: "toast"} }
        expect(@tree.common_label("toaster")).to eq("toast")
      end

      it do
        @tree.children = { "t" => {label: "toaster"} }
        expect(@tree.common_label("toaster")).to eq("toaster")
      end

      it do
        @tree.children = { "t" => {label: "t"} }
        expect(@tree.common_label("toasting")).to eq("t")
      end
    end

    describe "when there is no common label" do
      it do
        @tree.children = { "t" => {label: "toast"} }
        expect(@tree.common_label("manger")).to eq("")
      end

      it do
        @tree.children = { "t" => {label: "toast"} }
        expect(@tree.common_label("tomato")).to eq("")
      end

      it do
        @tree.children = { "t" => {label: "toast"} }
        expect(@tree.common_label("titi")).to eq("")
      end
    end
  end
  describe "#common_sub_label" do

    before(:each) do
      @tree = PatriciaTree.new
    end

    describe "when there is a common sub label" do
      it do
        @tree.children = { "t" => {label: "toast"} }
        expect(@tree.common_sub_label("toaster")).to eq("toast")
      end

      it do
        @tree.children = { "t" => {label: "toaster"} }
        expect(@tree.common_sub_label("toaster")).to eq("toaster")
      end

      it do
        @tree.children = { "t" => {label: "toasted"} }
        expect(@tree.common_sub_label("toas")).to eq("toas")
      end

      it do
        @tree.children = { "t" => {label: "toast"} }
        expect(@tree.common_sub_label("tomato")).to eq("to")
      end

      it do
        @tree.children = { "t" => {label: "toast"} }
        expect(@tree.common_sub_label("titi")).to eq("t")
      end
    end

    describe "when there is no common sub label" do
      it do
        @tree.children = { "t" => {label: "toast"} }
        expect(@tree.common_sub_label("manger")).to eq("")
      end
    end
  end
  describe "#common_prefix" do

    before(:each) do
      @tree = PatriciaTree.new
    end

    describe "when there is a no common prefix" do
      it {expect(@tree.common_prefix("toast", "toaster")).to eq("toast") }
      it {expect(@tree.common_prefix("toaster", "toast")).to eq("toast") }
      it {expect(@tree.common_prefix("manger", "gogogogo")).to eq("") }
      it {expect(@tree.common_prefix("toaster", "tomato")).to eq("to") }
    end
  end
end
