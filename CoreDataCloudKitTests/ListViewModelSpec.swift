import Quick
import Nimble
import CoreDataCloudKit
import CoreData

class ListViewModelSpec: QuickSpec {
    override func spec() {

        describe("ViewModel"){
         
            var vm: ListViewModel!
            var persistence: MCPersistenceFakeController!
            
            beforeEach{
                persistence = MCPersistenceFakeController()
                vm = ListViewModel(persistenceController: persistence)
            }
            afterEach{
                vm = nil
                persistence = nil
            }
            
            
            describe("its CRUD management"){
                
                it("has a persistence stack"){
                    expect(persistence).toNot(beNil())
                }
                it("starts with empty DB"){
                    var error: NSError?
                    let request = NSFetchRequest(entityName: "Item")
                    let count = persistence.managedContext.countForFetchRequest(request, error: &error)
                    
                    expect(error).to(beNil())
                    expect(count).to(equal(0))
                }
                it("can create an item and fetch it back"){
                    persistence
                }
                it("can delete an item"){
                    persistence
                }
            }
        }
    }
}
