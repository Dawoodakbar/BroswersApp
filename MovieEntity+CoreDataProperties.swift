//
//  MovieEntity+CoreDataProperties.swift
//  MovieBrowserApp
//
//  Created by dawood on 8/22/25.
//
//

import Foundation
import CoreData


extension MovieEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieEntity> {
        return NSFetchRequest<MovieEntity>(entityName: "MovieEntity")
    }

    @NSManaged public var id: Int32
    @NSManaged public var overview: String?
    @NSManaged public var popularity: Double
    @NSManaged public var posterPath: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var title: String?
    @NSManaged public var voteAverage: Double
    @NSManaged public var backdropPath: String?
    @NSManaged public var genreIds: [Int]

}

extension MovieEntity : Identifiable {

}
