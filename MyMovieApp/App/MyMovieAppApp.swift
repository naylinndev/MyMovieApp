//
//  MyMovieAppApp.swift
//  MyMovieApp
//
//  Created by Nay Lin on 2025/08/16.
//

import SwiftUI

@main
struct MyMovieAppApp: App {
    var body: some Scene {
        WindowGroup {
            HomeViewFactory.create()
        }
    }
}
