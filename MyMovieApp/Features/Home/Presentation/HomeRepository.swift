//
//  HomeRepository.swift
//  MyMovieApp
//
//  Created by Nay Lin on 2025/08/17.
//

import RxSwift
import RxMoya
import Moya

// Domain Layer - Protocol
protocol HomeRepositoryType {
    func fetchHome() -> Single<HomeMovieList>
}

// Data Layer - Implementation
class HomeRepository: HomeRepositoryType {
    private let provider: MoyaProvider<NetAPI>
    
    init(provider: MoyaProvider<NetAPI> = MoyaProvider<NetAPI>()) {
        self.provider = provider
    }

    
    func fetchHome() -> Single<HomeMovieList> {
        provider.rx.request(NetAPI.getHomeMovies)
            .filterSuccessfulStatusCodes()
            .map(HomeMovieList.self)
    }
    
}
