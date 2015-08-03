import CoreDataCloudKit
import CoreData
import Quick
import Nimble
import ReactiveCocoa

class ListViewModelSpec: QuickSpec {
    
    func saveAndCatch(moc: NSManagedObjectContext){
        var error: NSError? = nil;
        moc.save(&error)
        expect(error).to(beFalsy())
    }
    
    override func spec() {

        describe("ViewModel"){
         
            var vm: ListViewModel!
            var p: MCPersistenceFakeController!
            
            beforeEach{
                p = MCPersistenceFakeController()
                vm = ListViewModel(persistenceController: p)
            }
            afterEach{
                vm = nil
                p = nil
            }
            
            describe("Sanity"){
                it("has a persistence stack"){
                    expect(p).toNot(beNil())
                }
                it("starts with empty DB"){
                    var error: NSError?
                    let request = NSFetchRequest(entityName: "Item")
                    let count = p.managedContext.countForFetchRequest(request, error: &error)
                    
                    expect(error).to(beNil())
                    expect(count).to(equal(0))
                }
            }
            describe("its CRUD management"){
                
                it("can create an item and fetch it back"){
                    let item = vm.addNewItem()
                    self.saveAndCatch(p.managedContext)
                    
                    let fetchedItem = vm.itemForIndexPath(NSIndexPath(forRow: 0, inSection: 0))
                    expect(item).to(beIdenticalTo(fetchedItem))
                }
                
                it("can delete an item"){
                    let item = vm.addNewItem()
                    self.saveAndCatch(p.managedContext)
                    
                    expect(vm.numberOfRows).to(equal(1))
                    
                    vm.deleteItemWithIndexPath(NSIndexPath(forRow: 0, inSection: 0))
                    
                    expect(vm.numberOfRows).to(equal(0))
                }
            }
            
            describe("ReactiveCocoa tests"){
                it("can create an item and be notified"){
                    
                    var count = 0
                    var signal = vm.signal.observe(next: { i in
                        count++
                    })
                    
                    expect(count).to(equal(0))
                    
                    let item = vm.addNewItem()
                    self.saveAndCatch(p.managedContext)
                    
                    expect(count).to(equal(1))
                }
            }
        }
    }
}
