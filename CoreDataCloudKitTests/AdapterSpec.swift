import Quick
import Nimble
import CoreDataCloudKit

class AdapterSpec: QuickSpec {
    override func spec() {

        describe("Adapters"){
            var vm: ListViewModel!
            var p: MCPersistenceFakeController!
            
            beforeEach{
                p = MCPersistenceFakeController()
                vm = ListViewModel(persistenceController: p)
            }
//            afterEach{
//                vm = nil
//                p = nil
//            }
            
            describe("Array type"){
                context("With a set of Items"){
                    var items:Array<Item>!
                    
                    beforeEach{
                        let item = vm.addNewItem()
                        item.title = "Item one"
                        let item2 = vm.addNewItem()
                        item.title = "Item two"
                        let item3 = vm.addNewItem()
                        item.title = "Item three"
                        
                        self.saveAndCatch(p.managedContext)
                        
                        items = [item, item2, item3]
                    }
//                    afterEach{
//                        items = nil
//                    }
                    
                    
                    describe("Callbacks"){
                        
                        it ("calls willChangeContent properly"){
                            
                            let adapter = ArrayAdapter(initial: items)
                            
                            var willChange = false
                            var didChange = false
                            var newValues = []
                            
                            adapter.willChangeContent = { newObjects in
                                willChange = true
                                newValues = newObjects
                            }
                            adapter.didChangeContent = {
                                didChange = true
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
                            
                            adapter.willChangeContent = { newObjects in
                                willChange = true
                                newValues = newObjects
                            }
                            adapter.didChangeContent = {
                                didChange = true
                            }
                            
                            adapter.objects = []
                            
                            expect(willChange).to(beTrue())
                            expect(didChange).to(beTrue())
                            
                            expect(newValues).to(beEmpty())
                        }
                        
                    }
                }
            }
        }
    }
}
