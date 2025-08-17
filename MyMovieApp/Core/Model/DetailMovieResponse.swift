//
//  DetailMovieResponse.swift
//  MyMovieApp
//
//  Created by Nay Lin on 2025/08/16.
//
import Foundation

struct DetailMovie : Decodable {
    let adult : Bool
    let backdropPath : String
    let budget: Int
    let genres: [Genre]
    let id: Int
    let imdbId : String
    let originalTitle : String
    let overview : String
    let popularity : Double
    let posterPath : String
    let releaseDate : String
    let runtime: String
    let voteAverage : Double
    let voteCount : Int
    
    enum CodingKeys : String, CodingKey {
        case adult,budget,genres,id,overview,popularity,runtime
        case backdropPath = "backdrop_path"
        case imdbId = "imdb_id"
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    
    
}
