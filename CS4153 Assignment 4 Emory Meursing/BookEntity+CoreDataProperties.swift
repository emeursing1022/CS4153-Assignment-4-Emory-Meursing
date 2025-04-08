//
//  BookEntity+CoreDataProperties.swift
//  CS4153 Assignment 4 Emory Meursing
//
//  Created by Sarah Luster on 4/7/25.
//
//

import Foundation
import CoreData


extension BookEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookEntity> {
        return NSFetchRequest<BookEntity>(entityName: "BookEntity")
    }

    @NSManaged public var authors: String?
    @NSManaged public var bookDescription: String?
    @NSManaged public var coverImageUrl: String?
    @NSManaged public var id: String?
    @NSManaged public var publisher: String?
    @NSManaged public var title: String?

}

extension BookEntity : Identifiable {

}
