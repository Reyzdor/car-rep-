//
//  BookingEntity+CoreDataProperties.swift
//  NewCourseProject
//
//  Created by Roman on 05.11.2025.
//
//

public import Foundation
public import CoreData


public typealias BookingEntityCoreDataPropertiesSet = NSSet

extension BookingEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookingEntity> {
        return NSFetchRequest<BookingEntity>(entityName: "BookingEntity")
    }

    @NSManaged public var book_session: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var status: Bool
    @NSManaged public var carBrand: String?
    @NSManaged public var carID: UUID?
    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var amount: Double
    @NSManaged public var isActive: Bool
    @NSManaged public var user: UserEntity?

}

extension BookingEntity : Identifiable {

}
