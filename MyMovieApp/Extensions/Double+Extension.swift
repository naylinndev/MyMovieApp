//
//  Double+Extension.swift
//  MyMovieApp
//
//  Created by Nay Lin on 2025/08/17.
//

import Foundation

extension Double {
    /// Rounds the double to `places` decimal digits
    func rounded(toPlaces places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}
