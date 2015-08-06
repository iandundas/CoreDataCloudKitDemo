import Quick
import Nimble
import CoreData
import CoreDataCloudKit

class MapViewModelSpec: QuickSpec {
    override func spec() {
        
        var viewModel: MapViewModel!
        var p: MCPersistenceFakeController!
        
        beforeEach{
            p = MCPersistenceFakeController()
        }
        
        context("Array Adapter"){
            
            var adapter: ArrayAdapter!
            
            beforeEach{
                adapter = ArrayAdapter(initial: [])
                viewModel = MapViewModel(persistence: p, newAdapter: adapter)
            }
            
            describe("starting state"){
                it("should have an empty array"){
                    expect(viewModel.items.value.count).to(equal(0))
                }
            }
            
            describe("having some items"){
                
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
                
                it("should have the new items when they're added"){
                    
                    var itemCount = 0
                    viewModel.items.producer.start(next: { newArray in
                        itemCount = newArray.count
                    })
                    
                    expect(itemCount).to(equal(0))
                    
                    adapter.objects = items
                    
                    expect({return itemCount}).toEventually(equal(items.count))
                }
                
                it("should have the new items to start with"){
                    
                    adapter.objects = items
                    expect(viewModel.items.value.count).to(equal(items.count))
                }
                
                it("should have the new items when adapter is replaced"){
                    
                    var itemCount = 0
                    viewModel.items.producer.start(next: { newArray in
                        itemCount = newArray.count
                    })
                    
                    expect(itemCount).to(equal(0))
                    
                    let newAdapter = ArrayAdapter(initial: [items[0]])
                    viewModel.adapter = newAdapter
                    
                    expect({return itemCount}).toEventually(equal(1))
                }
            }
        }
        
        context("FRC Adapter"){
            var adapter: FRCAdapter!
            
            beforeEach{
                viewModel = MapViewModel(persistence: p, newAdapter: adapter)
            }
            
            // can't be arsed, context("Changing Adapter type") works fine
        }
        
        
        context("Changing Adapter type"){
            
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
            
            it("should update when switching adapter type"){
                
                let frc = self.quick_frc(NSPredicate(value: true), moc: p.managedContext)
                
                let arrayAdapter = ArrayAdapter(initial: [items[0]])
                let frcAdapter = FRCAdapter(fetchedResultsController: frc)
                
                let viewModel = MapViewModel(persistence: p, newAdapter: arrayAdapter)
                
                expect(viewModel.items.value.count).to(equal(1))
                
                // now switch the adapter and see what happens:
                
                // (we also want to get a callback that the items have changed)
                var itemCount = 0
                viewModel.items.producer.start(next: { newArray in
                    itemCount = newArray.count
                })
                 
                viewModel.adapter = frcAdapter
                
                expect(viewModel.items.value.count).to(equal(3))
                
                // check that callback was called:
                expect({return itemCount}).toEventually(equal(items.count))
                
            }
        }
    }
}
