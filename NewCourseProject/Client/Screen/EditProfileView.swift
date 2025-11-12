import SwiftUI
import CoreData

struct EditProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var password: String = ""

    var body: some View {
        ZStack {
            Color(red: 0.75, green: 0.15, blue: 1.0).ignoresSafeArea()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    Spacer()
                }
                .padding()

                VStack(spacing: 14) {
                    TextField("Имя", text: $name)
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .autocapitalization(.words)
                        .disableAutocorrection(false)

                    TextField("Email", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(false)

                    TextField("Телефон", text: $phone)
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .keyboardType(.phonePad)

                    SecureField("Пароль", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)

                Button(action: saveChanges) {
                    Text("Сохранить")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.0, green: 1.0, blue: 0.0))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .onAppear {
            name = authManager.userName
            email = authManager.userEmail
            phone = authManager.currentUser?.phone ?? ""
            password = authManager.currentUser?.password ?? ""
        }
    }

    private func saveChanges() {
        authManager.userName = name
        authManager.userEmail = email
        if let user = authManager.currentUser {
            user.name = name
            user.email = email
            user.phone = phone
            user.password = password
            let context = CoreDataManager.shared.viewContext
            do {
                try context.save()
            } catch {
                print("Ошибка при сохранении изменений: \(error.localizedDescription)")
            }
        }
        dismiss()
    }
}
