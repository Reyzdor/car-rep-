//
//  UserEntity+CoreDataProperties.swift
//  NewCourseProject
//
//  Created by Roman on 05.11.2025.
//
//

public import Foundation
public import CoreData


public typealias UserEntityCoreDataPropertiesSet = NSSet

extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var email: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var password: String?
    @NSManaged public var phone: String?
    @NSManaged public var registrationDate: Date?
    @NSManaged public var bookings: BookingEntity?

}

extension UserEntity : Identifiable {

}
