import Foundation
import Combine

final class RegisterViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let authService = AuthService()

    func register(completion: @escaping (Result<UserEntity, Error>) -> Void) {
        errorMessage = nil

        guard !name.isEmpty, !email.isEmpty, !phone.isEmpty, !password.isEmpty else {
            errorMessage = "Заполните все поля."
            completion(.failure(ValidationError.missingFields))
            return
        }

        guard email.contains("@") else {
            errorMessage = "Некорректный email."
            completion(.failure(ValidationError.invalidEmail))
            return
        }

        guard isValidRussianPhone(phone) else {
            errorMessage = "Некорректный номер телефона."
            completion(.failure(ValidationError.invalidPhone))
            return
        }

        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let user = try self.authService.register(name: self.name,
                                                         email: self.email,
                                                         phone: self.phone,
                                                         password: self.password)
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(.success(user))
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    }

    private func isValidRussianPhone(_ phone: String) -> Bool {
        let pattern = #"^(?:\+7|8)\d{10}$"#
        return phone.range(of: pattern, options: .regularExpression) != nil
    }

    enum ValidationError: Error {
        case missingFields
        case invalidEmail
        case invalidPhone
    }
}
