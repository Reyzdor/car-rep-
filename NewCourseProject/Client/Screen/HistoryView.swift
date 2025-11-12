import SwiftUI
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.dismiss) var dismiss
    @State private var bookings: [NSManagedObject] = []

    var body: some View {
        ZStack {
            Color(red: 0.75, green: 0.15, blue: 1.0).ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    Spacer()
                    Text("История поездок")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    Spacer()
                    
                    Button(action: clearHistory) {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
                .padding()

                if bookings.isEmpty {
                    Spacer()
                    Text("Нет завершенных поездок")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                } else {
                    List {
                        ForEach(bookings.indices, id: \.self) { index in
                            let booking = bookings[index]
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Поездка #\((booking.value(forKey: "id") as? UUID)?.uuidString.prefix(8) ?? "—")")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Авто: \(booking.value(forKey: "carBrand") as? String ?? "—")")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Начало:")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                        Text(formattedDate(booking.value(forKey: "startTime") as? Date))
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading) {
                                        Text("Конец:")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                        Text(formattedDate(booking.value(forKey: "endTime") as? Date))
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                }
                                
                                Text("Статус: \((booking.value(forKey: "status") as? Bool ?? false) ? "Выполнено" : "Отменено")")
                                    .font(.subheadline)
                                    .foregroundColor((booking.value(forKey: "status") as? Bool ?? false) ? .green : .orange)
                            }
                            .padding(.vertical, 8)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                }

                Button(action: { dismiss() }) {
                    Text("Закрыть")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.0, green: 1.0, blue: 0.0))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { fetchBookings() }
    }

    private func fetchBookings() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "BookingEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]

        do {
            bookings = try moc.fetch(request)
        } catch {
            print("Fetch error: \(error)")
            bookings = []
        }
    }

    private func clearHistory() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BookingEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try moc.execute(deleteRequest)
            try moc.save()
            bookings.removeAll()
            print("✅ История очищена")
        } catch {
            print("❌ Ошибка очистки истории: \(error)")
        }
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "—" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
