//
//  HomeView.swift
//  MyMovieApp
//
//  Created by Nay Lin on 2025/08/17.
//
import SwiftUI
import Kingfisher

struct HomeViewFactory {
    static func create() -> some View {
        let repository = HomeRepository(provider: netApi)
        let useCase = DefaultFetchHomeUseCase(repository: repository)
        let viewModel = HomeViewModel(fetchHomeUseCase: useCase)
        return HomeView(viewModel: viewModel)
    }
}

struct HomeView: View {
    private let menuItems: [String] = ["house.fill", "magnifyingglass", "heart.fill", "person.fill"]
    @StateObject private var viewModel: HomeViewModel
    @State var currentSelectedIndex: Int = 0
    
    @State private var selectedMovie: HomeMovie?
    @State private var showDetail: Bool = false
    
    @State private var selectedMenuIndex: Int = 0
    
    
    @State private var isScrollingDown = false
    @State private var lastScrollOffset: CGFloat = 0
    @State private var isScrolling = false
    @State private var hideTimer: Timer?
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom){
            ScrollView {
                ZStack(alignment: .top) {
                    
                    // Background content
                    backgroundContent
                    
                    // Main content
                    mainContent
                    
                    GeometryReader { geo in
                        Color.clear
                            .preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geo.frame(in: .named("scroll")).minY
                            )
                    }
                    .frame(height: 0)
                    
                }
                .frame(maxWidth: .infinity)
            }
            .coordinateSpace(name: "scroll") // Add coordinate space
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                handleScrollOffsetChange(value: value)
            }
            .background(Color.black)
            .ignoresSafeArea(edges: .all)
            .overlay(loadingOverlay)
            .errorAlert(error: $viewModel.error, retryAction: viewModel.fetchMovie)
            .onAppear(perform: viewModel.fetchMovie)
            
            
            bottomMenuBar
                .offset(y: isScrolling ? 100 : 30)
                .opacity(isScrolling ? 0 : 1)
                .animation(.easeInOut(duration: 0.3), value: isScrolling)
            
        }
        
    }
    
    private func handleScrollOffsetChange(value: CGFloat) {
        // Calculate scroll velocity
        let velocity = value - lastScrollOffset
        
        // Only consider significant movements to prevent flickering
        if abs(velocity) > 1 {
            // Scrolling is happening
            isScrolling = true
            
            // Reset any existing timer
            hideTimer?.invalidate()
            
            // Set a timer to detect when scrolling stops
            hideTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                isScrolling = false
            }
        }
        
        lastScrollOffset = value
    }
    
    // MARK: - Bottom Menu Bar
    private var bottomMenuBar: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let tabWidth = width / CGFloat(menuItems.count)
            let indicatorX = tabWidth * (CGFloat(selectedMenuIndex) + 0.5)
            
            ZStack(alignment: .top) {
                // Curved background with extended top for the indicator
                Capsule()
                    .fill(Color.gray)
                    .frame(height: 70)
                
                // Moving indicator with bottom half stroke
                ZStack {
                    // Main circle
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 15, height: 15)
                    
                    // Bottom half stroke
                    Circle()
                        .trim(from: 0.5, to: 1.0) // Only show bottom half
                        .rotation(Angle(degrees: 180))
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 17, height: 17) // Slightly larger for stroke visibility
                }
                .position(x: indicatorX, y: 0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedMenuIndex)
                
                
                // Tab items
                HStack(spacing: 0) {
                    ForEach(0..<menuItems.count, id: \.self) { index in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedMenuIndex = index
                            }
                        }) {
                            Image(systemName: menuItems[index])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(index == selectedMenuIndex ? .white : .white.opacity(0.6))
                                .frame(width: tabWidth, height: 50)
                        }
                    }
                }
                .padding(.top, 10)
            }
            .frame(width: width, height: 70)
        }
        .frame(height: 70)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: - Subviews
    
    private var backgroundContent: some View {
        Group {
            if let bannerMovie = currentBannerMovie {
                KFImage(URL(string: "\(Const.TMDB_w780)\(bannerMovie.backdropPath)"))
                    .retry(maxCount: 3, interval: .seconds(15))
                    .frame(width: UIScreen.main.bounds.width)
                    .scaledToFit()
            }
            
            LinearGradient(
                gradient: Gradient(colors: [
                    .black.opacity(0.4),
                    .black.opacity(0.9),
                    .black.opacity(1),
                    .black
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: UIScreen.main.bounds.height)
        }
    }
    
    private var mainContent: some View {
        VStack(alignment: .center, spacing: 4) {
            carouselSection
            movieInfoSection
            movieListSection
        }
        .padding(.bottom, 20)
        
    }
    
    private var carouselSection: some View {
        Group {
            if !viewModel.bannerImages().isEmpty {
                CarouselView(
                    images: viewModel.bannerImages(),
                    currentIndex: $currentSelectedIndex,
                    onImageTap: { index in
                        self.selectedMovie = viewModel.homeMovieList?.bannerMovies[index]
                        self.showDetail.toggle()
                    }
                )
                .padding(.top, 50)
                .frame(height: 380)
            }
        }
    }
    
    private var movieInfoSection: some View {
        Group {
            if let bannerMovie = currentBannerMovie {
                Text(bannerMovie.releaseDate.toDisplayDate() ?? "-")
                    .font(.system(.body, design: .serif))
                    .foregroundColor(.gray)
                
                Text(bannerMovie.title)
                    .font(.system(.title3, design: .serif, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                HStack(spacing: 10) {
                    infoCapsule(text: bannerMovie.releaseDate.toDisplayYear() ?? "")
                    
                    ratingCapsule(rating: bannerMovie.voteAverage)
                }
            }
        }
    }
    
    private var movieListSection: some View {
        Group {
            if let homeMovies = viewModel.homeMovieList?.homeMovies {
                ForEach(homeMovies, id: \.title) { movieCategory in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(movieCategory.title)
                            .font(.system(size: 18, weight: .regular, design: .serif))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.leading, 10)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 13) {
                                ForEach(movieCategory.data.indices, id: \.self) { i in
                                    moviePoster(movieDetail: movieCategory.data[i])
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func infoCapsule(text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .regular, design: .serif))
            .foregroundColor(.white)
            .padding(.horizontal, 15)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.white.opacity(0.3)))
    }
    
    private func ratingCapsule(rating: Double) -> some View {
        HStack(spacing: 5) {
            Image(systemName: "star.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
                .foregroundColor(.yellow)
            
            Text(String(format: "%.1f", rating))
                .font(.system(size: 16, weight: .regular, design: .serif))
                .foregroundColor(.yellow)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.white.opacity(0.3)))
    }
    
    private func moviePoster(movieDetail: HomeMovie) -> some View {
        KFImage(URL(string: "\(Const.TMDB_w780)\(movieDetail.posterPath)"))
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .clipped()
            .cornerRadius(10)
            .shadow(radius: 5)
            .onTapGesture {
                selectedMovie = movieDetail
                showDetail.toggle()
            }
        
    }
    
    private var loadingOverlay: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var currentBannerMovie: HomeMovie? {
        guard let bannerMovies = viewModel.homeMovieList?.bannerMovies,
              currentSelectedIndex >= 0,
              currentSelectedIndex < bannerMovies.count else {
            return nil
        }
        return bannerMovies[currentSelectedIndex]
    }
    
    // Preference key to track scroll offset
    struct ScrollOffsetPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
}

// MARK: - Error Alert Extension

extension View {
    func errorAlert(error: Binding<Error?>, retryAction: @escaping () -> Void) -> some View {
        alert("Error", isPresented: .constant(error.wrappedValue != nil)) {
            Button("Retry") {
                retryAction()
                error.wrappedValue = nil
            }
            Button("Cancel", role: .cancel) {
                error.wrappedValue = nil
            }
        } message: {
            Text(error.wrappedValue?.localizedDescription ?? "Unknown error")
        }
    }
}

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let repository = HomeRepository(provider: netStubApi)
        let useCase = DefaultFetchHomeUseCase(repository: repository)
        let viewModel = HomeViewModel(fetchHomeUseCase: useCase)
        HomeView(viewModel: viewModel)
    }
}
