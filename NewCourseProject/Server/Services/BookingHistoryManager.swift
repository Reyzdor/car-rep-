import Foundation
import CoreData

struct BookingHistoryManager {
    static func saveBooking(carBrand: String, carID: UUID, startTime: Date, endTime: Date, status: Bool, context: NSManagedObjectContext) {
        let duration = endTime.timeIntervalSince(startTime)
        guard duration >= 10 else { return }

        let booking = NSEntityDescription.insertNewObject(forEntityName: "BookingEntity", into: context) as! BookingEntity
        
        booking.id = UUID()
        booking.carBrand = carBrand
        booking.carID = carID
        booking.startTime = startTime
        booking.endTime = endTime
        booking.status = status
        booking.book_session = Date()

        do {
            try context.save()
            print("✅ Booking saved to history!")
        } catch {
            print("❌ Ошибка сохранения брони в историю: \(error)")
        }
    }
}
