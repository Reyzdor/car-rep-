import CoreData

struct PersistenceController {
    static let shared: PersistenceController = {
        let controller = PersistenceController(container: {
            let container = NSPersistentContainer(name: "Model")
            container.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Unresolved error \(error.localizedDescription)")
                }
            }
            return container
        }())
        return controller
    }()
    
    static let preview: PersistenceController = {
        let controller = PersistenceController(container: {
            let container = NSPersistentContainer(name: "Model")
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
            container.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Unresolved error \(error.localizedDescription)")
                }
            }
            return container
        }())
        return controller
    }()

    let container: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.container = container
    }
}
