import Quick
import Nimble
import CoreData
import CoreDataCloudKit

class ModelSpec: QuickSpec {
    
    override func spec() {

        describe("Model"){
            
            var moc: NSManagedObjectContext!
            
            beforeEach({
                moc = setUpInMemoryManagedObjectContext()
            })
            
            afterEach({
                moc = nil
            })
            
            it("is initialised"){
                var description = NSEntityDescription.entityForName("Item", inManagedObjectContext: moc)
                expect(description).toNot(beNil())
            }
            
            it("is able to insert and verify an object"){
                
                let entity:Item = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: moc) as! Item
                expect(entity).to(beAnInstanceOf(Item.self))
                
                entity.title = "New List Item"
                entity.created = NSDate()
                
                var error: NSError? = nil
                moc.save(&error)
                expect(error).to(beNil())
                
                let request = NSFetchRequest(entityName: "Item")
                let count = moc.countForFetchRequest(request, error: &error)
                expect(error).to(beNil())
                expect(count).to(equal(1))
            }
            
            
            describe("extensions"){
                
                it("has the right entityName"){
                    expect(Item.entityName()).to(equal("Item"))
                }
                
                context("there are some items"){
                    
                    
                }
                context("there are no items"){
                    
                    it("should calculate the total count correctly"){
                        expect(Item.countWithMOC(moc)).to(equal(0))
                    }
                    
                }
                
            }
        }
    }
}


// Swift 2.0: use protocols with default implementations here instead (don't want to subclass if we can avoid it)
extension NSManagedObject{
    
    static func countWithMOC(moc: NSManagedObjectContext)->Int{
        var error:NSError? = nil
        let request = NSFetchRequest(entityName: "Item")
        let count = moc.countForFetchRequest(request, error: &error)
        
        return count
    }
    
    class func entityName() -> String {
        let fullClassName = NSStringFromClass(object_getClass(self))
        let nameComponents = split(fullClassName) { $0 == "." }
        return last(nameComponents)!
    }
}

