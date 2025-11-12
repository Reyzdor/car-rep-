import SwiftUI

private let onboardingBackground = Color(red: 0.75, green: 0.15, blue: 1.0)
private let onboardingButtonColor = Color(red: 0.0, green: 1.0, blue: 0.0)

struct RegisterView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var vm = RegisterViewModel()
    @State private var goToMain = false
    @AppStorage("didRegister") private var didRegister: Bool = false

    var onRegistrationComplete: (() -> Void)? = nil

    var body: some View {
        ZStack {
            onboardingBackground
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer(minLength: 60)

                Text("Регистрация")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 14) {
                    AuthInputField(placeholder: "Имя", text: $vm.name)
                    AuthInputField(placeholder: "Email", text: $vm.email, keyboard: .emailAddress)
                    AuthInputField(placeholder: "Телефон", text: $vm.phone, keyboard: .phonePad)
                    AuthInputField(placeholder: "Пароль", text: $vm.password, isSecure: true)
                }

                if let err = vm.errorMessage {
                    Text(err)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 6)
                }

                Button(action: {
                    vm.register { result in
                        switch result {
                        case .success(let user):
                            didRegister = true
                            authManager.login(user: user)
                            onRegistrationComplete?()
                            goToMain = true
                        case .failure: break
                        }
                    }
                }) {
                    if vm.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Зарегистрироваться")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(onboardingButtonColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }

                NavigationLink(destination: MainView()
                                .environmentObject(authManager),
                               isActive: $goToMain) {
                    EmptyView()
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
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
                    .disableAutocorrection(true)
                    .frame(height: 48)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboard)
                    .autocapitalization(.none)
                    .disableAutocorrection(false)
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
