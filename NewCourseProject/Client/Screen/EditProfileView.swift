import SwiftUI
import CoreData

struct EditProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var password: String = ""
    
    @State private var showEmailError = false
    @State private var showPhoneError = false

    var body: some View {
        ZStack {
            Color(red: 0.75, green: 0.15, blue: 1.0).ignoresSafeArea()

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

                    if showEmailError {
                        Text("Некорректный Email")
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.leading, 4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    TextField("Телефон", text: $phone)
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .keyboardType(.phonePad)

                    if showPhoneError {
                        Text("Некорректный номер телефона")
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.leading, 4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

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
            if let user = authManager.currentUser {
                name = user.name ?? ""
                email = user.email ?? ""
                phone = user.phone ?? ""
                password = user.password ?? ""
            } else {
                name = ""
                email = ""
                phone = ""
                password = ""
            }
        }
    }

    private func saveChanges() {
        if !isValidEmail(email) {
            showEmailError = true
            return
        }
        showEmailError = false
        
        if !isValidPhone(phone) {
            showPhoneError = true
            return
        }
        showPhoneError = false

        authManager.userName = name
        authManager.userEmail = email
        authManager.setPhone(from: phone)
        
        let context = CoreDataManager.shared.viewContext

        if let user = authManager.currentUser {
            user.name = name
            user.email = email
            user.password = password
            do {
                try context.save()
            } catch {
                print("Ошибка при сохранении изменений: \(error.localizedDescription)")
            }
        } else {
            let newUser = UserEntity(context: context)
            newUser.name = name
            newUser.email = email
            newUser.phone = phone
            newUser.password = password
            do {
                try context.save()
                authManager.login(user: newUser)
            } catch {
                print("Ошибка при регистрации: \(error.localizedDescription)")
            }
        }
        dismiss()
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    private func isValidPhone(_ phone: String) -> Bool {
        let regex = #"^(\+7|8)\d{10}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: phone)
    }
}
