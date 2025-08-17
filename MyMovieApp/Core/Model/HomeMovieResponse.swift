//
//  MovieResponse.swift
//  MyMovieApp
//
//  Created by Nay Lin on 2025/08/16.
//

import Foundation

struct HomeMovieList : Codable {
    let bannerMovies : [HomeMovie]
    let homeMovies : [HomeMovieCategory]
    
    
    enum CodingKeys : String, CodingKey {
        case bannerMovies = "banner_movies"
        case homeMovies = "home_movies"
    }
}

struct HomeMovieCategory : Codable {
    let title: String
    let data : [HomeMovie]
    
    enum CodingKeys : String, CodingKey {
        case title
        case data
    }
}


struct HomeMovie :  Codable {
    let adult : Bool
    let backdropPath : String
    let id: Int
    let originalTitle : String
    let title : String
    let overview : String
    let popularity : Double
    let posterPath : String
    let releaseDate : String
    let voteAverage : Double
    let voteCount : Int
    
    enum CodingKeys : String, CodingKey {
        case adult,id,overview,popularity,title
        case backdropPath = "backdrop_path"
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }

}

