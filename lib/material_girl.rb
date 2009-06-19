module MaterialGirl
  
  def self.parse(set, opts={})
    unless block_given?
      opts[:delimiter]  ||= '::'
      opts[:field]      ||= :path
    end
    root = Composite.new('root')
    set.each do |item|
      val = block_given? ? yield(item) : item[opts[:field]].to_s.split(opts[:delimiter])
      acc = nil # define in outer scope to set the :item
      val.compact.inject(root) do |acc,k|
        acc.children << Composite.new(k, acc) unless acc.children.any?{|i|i.label==k}
        acc.children.detect{|i|i.label==k}
      end
      # the last path item is always the object
      acc.children.last.object = item
    end
    root
  end

  class Composite

    attr_reader :label, :parent
    attr_accessor :object

    def initialize(label='', parent=nil)
      @label, @parent = label, parent
    end

    def children
      @children ||= []
    end

    def descendants
      self.children.map{|c|c.children + c.descendants}.flatten
    end

    def ancestors
      (self.parent and self.parent.parent) ? ([self.parent.parent] + self.parent.ancestors) : []
    end

    def siblings
      self.parent ? (self.parent.children - [self]) : []
    end

  end
  
end