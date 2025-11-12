import Foundation
import CoreData

final class AuthService {
    private let context = CoreDataManager.shared.viewContext

    func register(name: String, email: String, phone: String, password: String) throws -> UserEntity {
        let req: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        req.predicate = NSPredicate(format: "email == %@", email.lowercased())
        if let _ = try context.fetch(req).first { throw AuthError.emailAlreadyExists }
        let user = UserEntity(context: context)
        user.id = UUID()
        user.name = name
        user.email = email.lowercased()
        user.password = password
        user.registrationDate = Date()
        try context.save()
        return user
    }

    func login(email: String, password: String) throws -> UserEntity {
        let req: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        req.predicate = NSPredicate(format: "email == %@ AND password == %@", email.lowercased(), password)
        if let user = try context.fetch(req).first { return user }
        throw AuthError.invalidCredentials
    }

    enum AuthError: LocalizedError {
        case emailAlreadyExists
        case invalidCredentials
        var errorDescription: String? {
            switch self {
            case .emailAlreadyExists: return "Пользователь с таким email уже существует."
            case .invalidCredentials: return "Неверный email или пароль."
            }
        }
    }
}
