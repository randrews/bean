class Bean
  def self.create_bean fields={}
    Class.new Bean do |klass|
      fields.each do |name, type|
        klass.add_field name, type
      end
    end
  end

  def initialize args={}
    args.each do |field,value|
      send "#{field}=", value
    end
  end

  def self.add_field name, type
    attr_reader name.to_sym
    define_method "#{name}=".to_sym do |new_value|
      unless self.class.type_matches?(new_value, type)
        raise "Wrong type: #{new_value.inspect}, expected #{type.inspect}"
      end

      instance_variable_set "@#{name}", new_value
    end
  end

  def self.type_matches? value, type
    if type.nil?
      true

    elsif type.is_a? Class
      value.is_a? type

    elsif type.is_a? String
      value.class.name == type

    elsif type.is_a? Regexp
      value.class.name =~ type

    elsif type.is_a? Hash
      value.is_a? Hash and
        value.all?{|k,v|
        type_matches?(k,type.keys.first) and
        type_matches?(v,type.values.first)}

    elsif type.is_a? Enumerable
      value.is_a? type.class and
        value.all?{|x| type_matches?(x,type.first)}
    end
  end
end

def test
  foo_bean = Bean.create_bean(:foo=>{String => [Numeric]}, :bar=>/Bean$/)
  foo_bean.new :foo=>{"foo"=>[1,2,3.4]}
end
