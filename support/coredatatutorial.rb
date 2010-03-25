# CoreDataUtilityTutorial 
#
# Copyright 2009, Reborg
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

framework 'Cocoa'
framework 'CoreData'

module CoreDataUtilityTutorial

  ##
  # The ManagedObjectModel MOM keeps track of objects and their
  # relationships. It doesn't care about actual persistency which is
  # managed object context responsability
  def self.managed_object_model
    return @mom if @mom
    @mom = NSManagedObjectModel.new
    
    # create the entity
    run_entity = NSEntityDescription.new
    run_entity.name = "Run"
    run_entity.managedObjectClassName = "Run"
    @mom.entities = [run_entity]

    # create the Date attribute for the run entity
    date_attribute = NSAttributeDescription.new
    date_attribute.name = "date"
    date_attribute.attributeType = NSDateAttributeType
    date_attribute.optional = false

    # create the processID attribute for the Run entity
    id_attribute = NSAttributeDescription.new
    id_attribute.name = "processID"
    id_attribute.attributeType = NSInteger32AttributeType
    id_attribute.optional = false
    id_attribute.defaultValue = -1 

    # create a validation rule "must be greater than zero"
    lhs = NSExpression.expressionForEvaluatedObject
    rhs = NSExpression.expressionForConstantValue(0)
    validation_predicate = NSComparisonPredicate
      .predicateWithLeftExpression(
      lhs,
      rightExpression:rhs,
      modifier:NSDirectPredicateModifier,
      type:NSGreaterThanPredicateOperatorType,
      options:0)

    # attaching the validation rule to the idAttribute
    id_attribute.setValidationPredicates(
      [validation_predicate], 
      withValidationWarnings:["Process ID < 1"])
    
    # Attaching the properties we created to the Run entity
    run_entity.properties = [date_attribute, id_attribute]
    
    # This is the accessory internationalization dictionary 
    # to attach to the model
    localization_dictionary = {"Property/date/Entity/Run" => "Date",
      "Property/processID/Entity/Run" => "Process ID",
      "ErrorString/Process ID < 1" => "Process ID must not be less than 1"}
    @mom.localizationDictionary=localization_dictionary
    
    @mom
  end

  def self.applicationSupportFolder
    paths = NSSearchPathForDirectoriesInDomains(
      NSApplicationSupportDirectory, 
      NSUserDomainMask, 
      true)
    basePath = (paths.count > 0) ? paths[0] : NSTemporaryDirectory()
    fileManager = NSFileManager.defaultManager
    path = basePath
      .stringByAppendingPathComponent("CoredataUtilityTutorial")
    if !fileManager.fileExistsAtPath(path, isDirectory:nil)
      fileManager.createDirectoryAtPath(path, attributes:nil)
    end
    path
  end
  
  # The single instance managed object context acts as a bridge
  # between the object model and the actual persistence mechanism
  def self.managed_object_context
    return @moc if @moc
    @moc ||= NSManagedObjectContext.new
    
    # Here a new store coordinator (which knows about persistency)
    # is created with a link to the model. The context is then linked
    # to the store
    coordinator = NSPersistentStoreCoordinator
      .alloc
      .initWithManagedObjectModel(managed_object_model)
    @moc.persistentStoreCoordinator = coordinator
    
    # store as XML file
    url = NSURL
      .fileURLWithPath(applicationSupportFolder.to_s + "/cut.xml") 
    # pointer trick, translate the NSError *error declaration
    error = Pointer.new_with_type('@')
    new_store = coordinator
      .addPersistentStoreWithType(
        NSXMLStoreType, 
        configuration:nil, 
        URL:url, 
        options:nil, 
        error:error)
    unless new_store
      msg = error[0].localizedDescription ? 
        error[0].localizedDescription : "Unknown"
      puts "Store configuration error #{msg}"
    end 
    @moc

  end
  
end

class Run < NSManagedObject
  # This lifecycle method will be called right after a new instance
  # of the entity has been registered into the context. It is usfeul
  # for setting timestamps for example, because it will never be called again
  # But unfortunately it goes segmentation fault
  #def awakeFromInsert
  #  super.awakeFromInsert
  #  # date = DateTime.now
  #end
end

mom = CoreDataUtilityTutorial.managed_object_model  
puts "The object model was defined as:\n #{mom.description}"
puts "Created storage at #{CoreDataUtilityTutorial.applicationSupportFolder}"
moc = CoreDataUtilityTutorial.managed_object_context
run_entity = mom.entitiesByName[:Run]
puts "Retrieved entity description:\n #{run_entity.description}"

# Creating a new instance of the entity 
# attached to the descriptor and added to the context
run = Run.alloc.initWithEntity(run_entity, 
                               insertIntoManagedObjectContext:moc)

# Grabbing the process ID and set the attribute on the entity
run.processID = NSProcessInfo.processInfo.processIdentifier
# Don't even dare to assign a Time.now: segfault
run.date = NSDate.date

# Now saving the context where the instance is
# to save changes to the instance
error = Pointer.new_with_type('@')
unless moc.save(error)
  msg = error[0].localizedDescription ? 
    error[0].localizedDescription : "Unknown"
  puts "Error while saving entity #{msg}"
end

# Now creating a fetch request to read the stored entities
request = NSFetchRequest.new
request.entity = run_entity

# Creating an order by and adding it to the array
# of sort descriptors for the fetch request
sort_descriptor = NSSortDescriptor.alloc.initWithKey("date", ascending:true)
request.sortDescriptors = [sort_descriptor]

# Executing the query and looking for errors. All results
# stored in an nsarray
fetch_error = Pointer.new_with_type('@')
results = moc.executeFetchRequest(request, error:fetch_error)
if ((fetch_error[0] != nil) || (results == nil))
  msg = fetch_error[0].localizedDescription ? 
    fetch_error[0].localizedDescription : "Unknown"
  puts "Error fetching entity #{msg}"
end

# I need to format the date to display results, so I create a date
# formatter
formatter = NSDateFormatter.new
formatter.setDateStyle(NSDateFormatterMediumStyle)
formatter.setTimeStyle(NSDateFormatterMediumStyle)

# Iterating through the results logging what's in there
# using the formatter when necessary
puts "Actual run history:"
results.each do |run|
  puts "On #{formatter.stringForObjectValue(run.date)} #{run.processID}"
end
