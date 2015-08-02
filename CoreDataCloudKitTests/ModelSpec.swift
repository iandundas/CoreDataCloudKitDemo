import Quick
import Nimble
import CoreData
import CoreDataCloudKit

class ModelSpec: QuickSpec {
    
    override func spec() {

        describe("Model"){
            
            var p: MCPersistenceFakeController!
            var moc: NSManagedObjectContext!
            
            beforeEach({
                p = MCPersistenceFakeController()
                moc = p.managedContext
            })
            
            afterEach({
                moc = nil
            })
            
            it("is initialised"){
                var description = NSEntityDescription.entityForName("Item", inManagedObjectContext: moc)
                expect(description).toNot(beNil())
            }
            
            it("is able to insert and verify an object (shortform)"){
                
                let entity = moc.insert(Item)
                
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
                    expect(Item.entityName).to(equal("Item"))
                }
                
                context("there are some items"){
                    
                    var item1: Item!
                    var item2: Item!
                    var item3: Item!
                    
                    beforeEach({
                        item1 = moc.insert(Item)
                        item2 = moc.insert(Item)
                        item3 = moc.insert(Item)
                        
                    })
                    
                    
                    it("Should have a timestamp set"){
                        expect(item1?.created).toNot(beNil())
                    }
                    it("Should have a default title set"){
                        expect(item1?.title).to(equal(Item.defaults().Title))
                    }
                    
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
