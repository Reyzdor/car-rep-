import SwiftUI

private let onboardingBackground = Color(red: 0.75, green: 0.15, blue: 1.0)
private let onboardingButtonColor = Color(red: 0.0, green: 1.0, blue: 0.0)

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var vm = LoginViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                onboardingBackground
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer(minLength: 60)

                    Text("Вход")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 14) {
                        AuthInputField(placeholder: "Email", text: $email, keyboard: .emailAddress, isSecure: false)
                        AuthInputField(placeholder: "Пароль", text: $password, keyboard: .default, isSecure: true)
                    }

                    Button(action: {
                        attemptLogin()
                    }) {
                        HStack {
                            if vm.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Войти")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(onboardingButtonColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
                    }
                    .disabled(email.isEmpty || password.isEmpty || vm.isLoading)

                    NavigationLink(destination:
                                    RegisterView(onRegistrationComplete: {
                                        authManager.isLoggedIn = true
                                    })
                                    .environmentObject(authManager)
                    ) {
                        Text("Зарегистрироваться")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.9), lineWidth: 1)
                            )
                            .foregroundColor(.white)
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .alert("Ошибка", isPresented: $showError) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(errorMessage)
                }
            }
        }
    }

    private func attemptLogin() {
        vm.email = email
        vm.password = password
        vm.login { result in
            switch result {
            case .success(let user):
                authManager.login(user: user)
            case .failure:
                errorMessage = vm.error ?? "Неверный логин или пароль"
                showError = true
            }
        }
    }
}

private struct AuthInputField: View {
    var placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var isSecure: Bool = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textContentType(.password)
                    .keyboardType(keyboard)
                    .autocapitalization(.none)
                    .disableAutocorrection(false)
                    .frame(height: 48)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboard)
                    .autocapitalization(.none)
                    .disableAutocorrection(false)
                    .textContentType(.emailAddress)
                    .frame(height: 48)
            }
        }
        .padding(.horizontal, 14)
        .background(Color.white.opacity(0.15))
        .foregroundColor(.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}
