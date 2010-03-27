require 'singleton'

class Persistence

  include Singleton
  attr_writer :db_path, :bundles_path

  def reset
    @db_path = nil
    @bundles_path = nil
    @mom = nil
    @psc = nil
    @moc = nil
  end

  def db_path
    @db_path ||= default_store
  end

  def bundles_path
    @bundles_path ||= nil
  end

  def mom
    @mom ||= NSManagedObjectModel.mergedModelFromBundles(bundles_path)
  end

  def psc
    @psc ||= init_psc
  end

  def moc
    @moc ||= init_moc
  end

  def self.fetch(request)
    error = fetch_error
    results = Persistence.instance.moc.executeFetchRequest(request, error:error)
    process_error(error)
    results
  end

  def self.save
    error = fetch_error
    unless Persistence.instance.moc.save(error)
      msg = error[0].localizedDescription ?  error[0].localizedDescription : "Unknown"
      NSLog("Error while saving entity #{msg}")
      raise "Error on save: #{error[0].description}"
      return false
    end
    return true
  end

  def self.fetch_error
    Pointer.new_with_type('@')
  end  

  def self.process_error(error)
    unless error[0] == nil
      msg = error[0].localizedDescription ? error[0].localizedDescription : "Unknown"
      raise "CoreData access error: \n#{msg}"
    end
  end

  private 

    def init_moc
      moc = NSManagedObjectContext.new
      moc.persistentStoreCoordinator = psc
      moc
    end

    def init_psc
      psc = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(mom)
      url = NSURL.fileURLWithPath(db_path)
      error = Pointer.new_with_type('@')
      new_store = psc.addPersistentStoreWithType( NSXMLStoreType, configuration:nil, URL:url, options:nil, error:error)
      unless new_store
        msg = error[0].localizedDescription ? error[0].localizedDescription : "Unknown" 
        puts "Store configuration error #{msg}"
      end 
      psc
    end

    def default_store
      paths = NSSearchPathForDirectoriesInDomains( NSApplicationSupportDirectory, NSUserDomainMask, true)
      basePath = (paths.count > 0) ? paths[0] : NSTemporaryDirectory()
      fileManager = NSFileManager.defaultManager
      path = basePath.stringByAppendingPathComponent("Shortify")
      fileManager.createDirectoryAtPath(path, attributes:nil) unless fileManager.fileExistsAtPath(path, isDirectory:nil)
      path.to_s + "/shortify.xml"
    end

end
