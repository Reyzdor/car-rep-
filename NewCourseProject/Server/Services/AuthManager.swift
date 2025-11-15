import Foundation
import Combine
import CoreData

final class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool {
        didSet { UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn") }
    }
    
    @Published var userName: String {
        didSet { UserDefaults.standard.set(userName, forKey: "userName") }
    }
    
    @Published var userEmail: String {
        didSet { UserDefaults.standard.set(userEmail, forKey: "userEmail") }
    }
    
    @Published var currentUser: UserEntity?
    
    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        self.userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        self.userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        if isLoggedIn { fetchCurrentUser() }
    }
    
    func login(user: UserEntity) {
        currentUser = user
        userEmail = user.email ?? ""
        userName = user.name ?? ""
        isLoggedIn = true
    }
    
    func logout() {
        isLoggedIn = false
        userName = ""
        userEmail = ""
        currentUser = nil
    }
    
    private func fetchCurrentUser() {
        let context = CoreDataManager.shared.viewContext
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", userEmail)
        if let user = try? context.fetch(request).first {
            currentUser = user
            userName = user.name ?? ""
            userEmail = user.email ?? ""
        }
    }
    
    func getPhoneString() -> String {
        return currentUser?.phone ?? ""
    }
    
    func setPhone(from string: String) {
        guard let user = currentUser else { return }
        user.phone = string
        let context = CoreDataManager.shared.viewContext
        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении телефона: \(error.localizedDescription)")
        }
    }
}
