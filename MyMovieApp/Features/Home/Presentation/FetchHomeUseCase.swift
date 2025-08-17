//
//  FetchHomeUseCase.swift
//  MyMovieApp
//
//  Created by Nay Lin on 2025/08/17.
//
import RxSwift

protocol FetchHomeUseCase {
    func execute() -> Observable<HomeMovieList>
}


final class DefaultFetchHomeUseCase: FetchHomeUseCase {
    private let repository: HomeRepositoryType
    
    init(repository: HomeRepositoryType) {
        self.repository = repository
    }
    
    func execute() -> Observable<HomeMovieList> {
        return repository.fetchHome().asObservable()
    }
    
}

