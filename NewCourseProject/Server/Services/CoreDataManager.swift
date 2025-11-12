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


//CREATE TABLE UserEntity (
//    id UUID PRIMARY KEY,
//    email TEXT NOT NULL,
//    name TEXT,
//    password TEXT,
//    phone TEXT,
//    registrationDate DATE

//    FOREIGN KEY (bookingid) REFERENCES BookingEntity(id)
//);
//
//CREATE TABLE BookingEntity (
//    id UUID PRIMARY KEY,
//    book_session DATE,
//    carBrand TEXT,
//    carID UUID,
//    startTime DATE,
//    endTime DATE,
//    isActivate BOOLEAN,
//    status BOOLEAN,
//    userId UUID,
//
//    FOREIGN KEY (userId) REFERENCES UserEntity(id)
//);
//
