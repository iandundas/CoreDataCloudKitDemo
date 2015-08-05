import Quick
import Nimble
import CoreDataCloudKit
import CoreData

class AdapterSpec: QuickSpec {
    override func spec() {
        

        
        describe("Adapters"){
            var p: MCPersistenceFakeController!
            
            beforeEach{
                p = MCPersistenceFakeController()
            }
            
            describe("Array type"){
                context("With a set of Items"){
                    var items:Array<Item>!
                    
                    beforeEach{
                        let item = p.managedContext.insert(Item)
                        item.title = "Item one"
                        let item2 = p.managedContext.insert(Item)
                        item2.title = "Item two"
                        let item3 = p.managedContext.insert(Item)
                        item3.title = "Item three"
                        
                        self.saveAndCatch(p.managedContext)
                        
                        items = [item, item2, item3]
                    }
                    
                    
                    describe("Callbacks"){
                        
                        it ("calls willChangeContent properly"){
                            
                            let adapter = ArrayAdapter(initial: items)
                            
                            var willChange = false
                            var didChange = false
                            var newValues = []
                            
                            adapter.willChangeContent = {
                                willChange = true
                            }
                            adapter.didChangeContent = { newObjects in
                                didChange = true
                                newValues = newObjects
                            }
                            
                            // should not have changed yet
                            expect(willChange).to(beFalse())
                            expect(didChange).to(beFalse())
                            
                            var expected = Array(items[0...1])
                            adapter.objects = expected
                            
                            expect(willChange).to(beTrue())
                            expect(didChange).to(beTrue())

                            expect(newValues).to(contain(items[0], items[1]))
                        }
                        
                        it ("Handles being emptied properly"){
                            
                            let adapter = ArrayAdapter(initial: items)
                            
                            var willChange = false
                            var didChange = false
                            var newValues = []
                            
                            adapter.willChangeContent = {
                                willChange = true
                            }
                            adapter.didChangeContent = { newObjects in
                                didChange = true
                                newValues = newObjects
                            }
                            
                            adapter.objects = []
                            
                            expect(willChange).to(beTrue())
                            expect(didChange).to(beTrue())
                            
                            expect(newValues).to(beEmpty())
                        }
                        
                    }
                }
            }
            
            
            describe("FetchedResultsController type"){
                var items:Array<Item>!
                var frc: NSFetchedResultsController!
                
                beforeEach{
                    
                    frc = self.quick_frc(NSPredicate(value: true), moc: p.managedContext)
                    
                    // Also insert some sample Items:
                    let item = p.managedContext.insert(Item)
                    item.title = "Item one"
                    let item2 = p.managedContext.insert(Item)
                    item2.title = "Item two"
                    let item3 = p.managedContext.insert(Item)
                    item3.title = "Item three"
                    
                    self.saveAndCatch(p.managedContext)
                    
                    items = [item, item2, item3]
                }
                
                describe("Acts like a FRC"){
                    
                    it ("handles existing items properly"){
                        let adapter = FRCAdapter(fetchedResultsController: frc)

                        let existingObjects = adapter.objects
                        
                        expect(existingObjects).to(contain(items[0], items[1], items[2]))
                    }
                    
                    it ("handles inserts properly"){
                        let adapter = FRCAdapter(fetchedResultsController: frc)
                        
                        let priorCount = adapter.objects.count
                        
                        // Now add an item
                        let item4 = p.managedContext.insert(Item)
                        item4.title = "Newly created"

                        expect(adapter.objects.count).toEventually(equal(priorCount+1))
                        expect(adapter.objects).toEventually(contain(item4))
                    }
                    
                    it ("gives a callback as per Adapter protocol"){
                        let adapter = FRCAdapter(fetchedResultsController: frc)
                        
                        var willChange = false
                        var didChange = false
                        var newValues = []
                        
                        adapter.willChangeContent = {
                            willChange = true
                        }
                        adapter.didChangeContent = { newObjects in
                            didChange = true
                            newValues = newObjects
                        }
                        
                        // should not have changed yet
                        expect(willChange).to(beFalse())
                        expect(didChange).to(beFalse())
                        
                        // Now add an item
                        let item4 = p.managedContext.insert(Item)
                        item4.title = "Newly created"
                        
                        expect({return willChange == true}).toEventually(beTrue())
                        expect({return didChange == true}).toEventually(beTrue())
                        expect(newValues).toEventually(contain(item4))
                    }
                }
                
                describe("Replacing the FRC with another"){
                    
                    it("should refresh contents when FRC is replaced"){
                        let adapter = FRCAdapter(fetchedResultsController: frc)
                        
                        // check starting conditions
                        expect(adapter.objects.count).to(equal(3))
                        
                        let predicate = NSPredicate(format: "title CONTAINS 'three'", argumentArray: nil)
                        let new_frc = self.quick_frc(predicate, moc: p.managedContext)
                        adapter.fetchedResultsController = new_frc
                        
                        /* adapter should only contain one item after FRC switcheroo */
                        expect(adapter.objects.count).toEventually(equal(1))
                        
                        /* adapter should only contain items[2] (containing "three") now: */
                        expect(adapter.objects).toEventually(contain(items[2]))
                    }
                    
                    it("should fire callbacks when FRC is replaced, if members are different"){
                        let adapter = FRCAdapter(fetchedResultsController: frc)
                        
                        // check starting conditions
                        expect(adapter.objects.count).to(equal(3))
                        
                        var willChange = false
                        var didChange = false
                        var newValues = []
                        
                        /* We still want the callbacks to be triggered */
                        adapter.willChangeContent = {
                            willChange = true
                        }
                        adapter.didChangeContent = { newObjects in
                            didChange = true
                            newValues = newObjects
                        }
                        
                        // should not have changed yet
                        expect(willChange).to(beFalse())
                        expect(didChange).to(beFalse())
                        
                        let predicate = NSPredicate(format: "title CONTAINS 'three'", argumentArray: nil)
                        let new_frc = self.quick_frc(predicate, moc: p.managedContext)
                        adapter.fetchedResultsController = new_frc
                        
                        expect({return willChange == true}).toEventually(beTrue())
                        expect({return didChange == true}).toEventually(beTrue())
                        
                        /* callback's newValues array should have correct values */
                        expect(newValues).toEventually(contain(items[2]))
                    }
                    
                    it ("should not fire callback if there's no difference in members"){
                        let adapter = FRCAdapter(fetchedResultsController: frc)
                        
                        // check starting conditions
                        expect(adapter.objects.count).to(equal(3))
                        
                        var willChange = false
                        var didChange = false
                        
                        adapter.willChangeContent = {
                            willChange = true
                        }
                        adapter.didChangeContent = { newObjects in
                            didChange = true
                        }
                        
                        let predicate = NSPredicate(format: "title CONTAINS 'Item'", argumentArray: nil)
                        let new_frc = self.quick_frc(predicate, moc: p.managedContext)
                        adapter.fetchedResultsController = new_frc
                        
                        // Callback should never have been called:
                        expect({return willChange == false}).toEventually(beTrue())
                        expect({return didChange == false}).toEventually(beTrue())
                        
                        /* callback's newValues array should still have correct values */
                        expect(new_frc.fetchedObjects).toEventually(contain(items[0], items[1], items[2]))
                    }
                }
            }
        }
    }
}
