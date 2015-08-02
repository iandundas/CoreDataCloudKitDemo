import Quick
import Nimble
import CoreDataCloudKit

class MCPersistenceControllerSpec: QuickSpec {
    override func spec() {

        describe("Model") {
            
            describe("with SQL persistence stack") {
                it("can become ready") {
                    
                    // FIXME: can use this technique if still getting deadlocks:
                    // http://stackoverflow.com/questions/29504712/in-xcode-and-swift-how-can-i-get-xctest-to-wait-for-async-calls-in-setup-before
                    
                    var isReady = false
                    // Can now create the Persistence Controller
                    var persistenceController = MCPersistenceController(persistenceReady: {
                        // persistence stack is now ready
                        isReady = true
                        }, persistenceType: PersistenceType.SQLLite)
                    
                    expect(isReady).toEventually(beTruthy())
                }
            }
            describe("with In-Memory persistence stack") {
                it("can become ready") {
                    
                    var isReady = false
                    // Can now create the Persistence Controller
                    var persistenceController = MCPersistenceController(persistenceReady: {
                        // persistence stack is now ready
                        isReady = true
                        }, persistenceType: PersistenceType.SQLLite)
                    
                    expect(isReady).toEventually(beTruthy())
                }
            }
        }
    }
}
