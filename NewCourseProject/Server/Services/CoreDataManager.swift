import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            if let error = error { fatalError("CoreData loading error: \(error.localizedDescription)") }
        }
    }

    var viewContext: NSManagedObjectContext { container.viewContext }

    func save() {
        if viewContext.hasChanges {
            do { try viewContext.save() }
            catch { print("Error saving Core Data: \(error)") }
        }
    }
}
