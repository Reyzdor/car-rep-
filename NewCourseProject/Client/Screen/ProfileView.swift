import SwiftUI
import CoreData

private let onboardingBackground = Color(red: 0.75, green: 0.15, blue: 1.0)
private let onboardingButtonColor = Color(red: 0.0, green: 1.0, blue: 0.0)

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @AppStorage("didRegister") private var didRegister: Bool = false
    @State private var showEdit = false
    @Environment(\.managedObjectContext) private var context
    @State private var bookings: [NSManagedObject] = []

    @AppStorage("userBalance") private var balance: Double = 0.0
    @AppStorage("promoUsed") private var promoUsed: Bool = false

    @State private var showTopUp = false

    var body: some View {
        NavigationView {
            ZStack {
                onboardingBackground.ignoresSafeArea()

                VStack(spacing: 18) {
                    HStack {
                        Spacer()
                        Button(action: { showEdit.toggle() }) {
                            Image(systemName: "pencil")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.trailing, 16)

                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 110)
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.12))
                                    .frame(width: 140, height: 140)
                            )
                            .clipShape(Circle())
                            .shadow(radius: 6)

                        Text(authManager.userName.isEmpty ? "Имя неизвестно" : authManager.userName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text(authManager.userEmail.isEmpty ? "Email отсутствует" : authManager.userEmail)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.06)))
                    .padding(.horizontal)

                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Баланс")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("\(Int(balance)) ₽")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 10)
                        .padding(.leading, 14)

                        Spacer()

                        Button(action: { showTopUp = true }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Пополнить")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0)))
                        }
                        .padding(.trailing, 12)
                    }
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.04)))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.06)))

                    VStack(spacing: 12) {
                        ProfileRow(icon: "calendar",
                                   title: "Брони",
                                   value: "\(bookings.count)")

                        NavigationLink(destination: HistoryView().environment(\.managedObjectContext, context)) {
                            ProfileRow(icon: "clock",
                                       title: "История поездок",
                                       value: "\(bookings.count)")
                        }
                    }
                    .padding(.horizontal)

                    Spacer()

                    Button(action: { authManager.logout() }) {
                        Text("Выйти")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(onboardingButtonColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 18)
                }
                .padding(.top, 18)
                .sheet(isPresented: $showEdit) {
                    EditProfileView()
                        .environmentObject(authManager)
                }
                .sheet(isPresented: $showTopUp) {
                    TopUpView()
                        .environmentObject(authManager)
                }
            }
            .navigationBarHidden(true)
            .onAppear { fetchBookings() }
        }
    }

    private func fetchBookings() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "BookingEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        do {
            bookings = try context.fetch(request)
        } catch {
            print("Fetch error: \(error)")
            bookings = []
        }
    }
}

private struct ProfileRow: View {
    var icon: String
    var title: String
    var value: String

    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .labelStyle(TitleOnlyLabelStyle())
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .foregroundColor(.white.opacity(0.9))
                .font(.subheadline)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.06)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}
