//
//  HomeViewModel.swift
//  MyMovieApp
//
//  Created by Nay Lin on 2025/08/17.
//
import Foundation
import RxSwift

class HomeViewModel : ObservableObject {
    private let fetchHomeUseCase: FetchHomeUseCase
    private let disposeBag = DisposeBag()
    
    // Outputs
    @Published var homeMovieList: HomeMovieList?
    @Published var isLoading = false
    @Published var error: Error?
    
    
    init(fetchHomeUseCase: FetchHomeUseCase) {
        self.fetchHomeUseCase = fetchHomeUseCase
    }
    
    func bannerImages() -> [String] {
        guard let list = homeMovieList else { return [] }
        return list.bannerMovies.map { movie in
            "\(Const.TMDB_w780)\(movie.posterPath ?? "")"
        }
    }
    
    func fetchMovie() {
        isLoading = true
        error = nil
        
        let observable: Observable<HomeMovieList>
        
        observable = fetchHomeUseCase.execute()
        
        
        observable
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] movieList in
                    self?.homeMovieList = movieList
                    self?.isLoading = false
                },
                onError: { [weak self] error in
                    print(error)
                    self?.error = error
                    self?.isLoading = false
                }
            )
            .disposed(by: disposeBag)
    }
}
