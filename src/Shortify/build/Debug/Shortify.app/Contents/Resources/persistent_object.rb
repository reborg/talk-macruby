require 'persistence'

class PersistentObject < NSManagedObject

  def self.new(*args, &block)
    obj = self.alloc.initWithEntity(entity, insertIntoManagedObjectContext:Persistence.instance.moc)
    obj.send(:initialize, *args, &block)
    obj
  end

  def self.entity
    Persistence.instance.mom.entitiesByName[self.name]
  end

  def save
    Persistence.save
  end

  def self.create(params)
    new_instance = constantize(entity.name).new
    params.keys.each {|attr| new_instance.send("#{attr}=", params[attr])}
    new_instance.save
  end

  def self.create!(params)
    unless create(params)
      raise Exception, "Could not create entity"
    end
  end

  def self.all
    request = NSFetchRequest.new
    request.includesPendingChanges = false
    request.entity = entity
    Persistence.fetch(request)
  end

  def self.constantize(camel_cased_word)
    unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ camel_cased_word
      raise NameError, "#{camel_cased_word.inspect} is not a valid constant name!"
    end
    Object.module_eval("::#{$1}", __FILE__, __LINE__)
  end

end
