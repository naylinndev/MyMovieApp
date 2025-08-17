//
//  MovieRowView.swift
//  MyMovieApp
//
//  Created by Nay Lin on 2025/08/17.
//

import SwiftUI
import Kingfisher

struct MovieRowView: View {
    let movies: [HomeMovie]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(movies.indices, id: \.self) { i in
                    let movie = movies[i]
                    KFImage(URL(string: "\(Const.TMDB_w780)\(movie.posterPath)"))
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .padding(.horizontal)
        }
    }
}

