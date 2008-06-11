class SimpleDB
  
  class Base
    attr_accessor :key, :attributes
  
    def self.establish_connection!(opts)
      @@connection = Amazon::SDB::Base.new(opts[:access_key_id], opts[:secret_access_key])
    end
    
    def self.connection; @@connection; end
    
    class << self
      attr_accessor :domain_name
    end
    
    def self.domain
      @@connection.domain(self.domain_name)
    end
    
    def self.set_domain(d)
      self.domain_name = d
    end
    
    def self.properties(*props)
      props.each do |p|
        class_eval "def #{p}; self.get('#{p}'); end"
        class_eval "def #{p}=(v); self.put('#{p}', v); end"
      end
    end

    def initialize(key=nil, multimap_or_hash=nil)
      self.key = (key || UUID.new)
      self.attributes = multimap_or_hash.nil? ? Amazon::SDB::Multimap.new : (multimap_or_hash.kind_of?(Hash) ? Amazon::SDB::Multimap.new(multimap_or_hash) : multimap_or_hash)
    end

    def self.create(*values)
      key = UUID.new
      attributes = values.nil? ? Amazon::SDB::Multimap.new : Amazon::SDB::Multimap.new(*values)
      self.new(key, attributes)
    end

    def self.create!(*values)
      video = self.create(*values)
      video.save
      video
    end
    
    def get(key)
      reload! if self.attributes.size == 0
      self.attributes.coerce(self.attributes.get(key))
    end
    
    def [](key)
      self.get(key)
    end

    def put(key, value)
      self.attributes.put(key, value, :replace => true)
    end
    
    def []=(key, value)
      self.put(key, value)
    end

    def save
      self.class.domain.put_attributes(self.key, self.attributes, :replace => :all)
    end
    
    def destroy!
      self.class.domain.delete_attributes(self.key)
    end
    
    def reload!
      item = self.class.domain.get_attributes(@key)
      self.attributes = item.attributes
    end

    def self.find(key)
      self.new(key, self.domain.get_attributes(key).attributes)
    end

    def self.query(expr="", query_options={})
      result = []
      self.domain.query(query_options.merge({:expr => expr})).each do |i|
        result << self.new(i.key, i.attributes)
      end
    end
    
  private
  
    def method_missing(meth, *args)
      self.attributes.send(meth)
    end
  end
end