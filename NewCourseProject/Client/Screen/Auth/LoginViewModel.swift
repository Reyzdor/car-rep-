import Foundation
import Combine

final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var error: String?

    private let authService = AuthService()

    func login(completion: @escaping (Result<UserEntity, Error>) -> Void) {
        error = nil

        guard !email.isEmpty, !password.isEmpty else {
            error = "Введите email и пароль."
            completion(.failure(LoginError.missingFields))
            return
        }

        guard email.contains("@") else {
            error = "Некорректный email."
            completion(.failure(LoginError.invalidEmail))
            return
        }

        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let user = try self.authService.login(email: self.email, password: self.password)
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(.success(user))
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.error = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    }

    enum LoginError: Error {
        case missingFields
        case invalidEmail
    }
}
