//
//  GenresResponse.swift
//  MyMovieApp
//
//  Created by Nay Lin on 2025/08/16.
//

import Foundation

struct GenreList : Codable {
    let genres : [Genre]
}

struct Genre : Codable {
    let id : Int
    let name : String
}
