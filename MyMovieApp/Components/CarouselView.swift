//
//  CarouselView.swift
//  MyMovieApp
//
//  Created by Nay Lin on 2025/08/17.
//
//
//  CarouselView.swift
//  MyMovieApp
//

import SwiftUI
import Kingfisher

struct CarouselView: View {
    
    let images: [String]
    
    @Binding var currentIndex: Int
    @State private var internalIndex: Int = 0
    
    @State private var scrollOffset: CGFloat = 0
    @State private var isDragging = false
    var onImageTap: ((Int) -> Void)?
    var body: some View {
        GeometryReader { geo in
            let cardWidth: CGFloat = 200
            let spacing: CGFloat = -20
            let totalCardWidth = cardWidth + spacing
            let centerOffset = (geo.size.width - cardWidth) / 2
            
            ZStack {
                
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: spacing) {
                            ForEach(Array(images.enumerated()), id: \.0) { index, image in
                                GeometryReader { innerGeo in
                                    let midX = innerGeo.frame(in: .global).midX
                                    let centerX = geo.size.width / 2
                                    let distance = (midX - centerX) / centerX
                                    let isCenter = abs(distance) < 0.1 // Threshold for center detection
                                    
                                    let scale = isCenter ? 1.0 : max(0.8, 1 - abs(distance) * 0.4)
                                    let opacity = isCenter ? 1.0 : max(0.7, 1 - abs(distance) * 0.9)
                                    let rotation = calculateRotation(distance: distance)
                                    let zIndex = isCenter ? 2 : 1
                                    let offset = calculateOffset(distance: distance)
                                    
                                    
                                    VStack {
                                        KFImage(URL(string: image))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: cardWidth, height: 300)
                                            .clipped()
                                            .opacity(opacity)
                                            .cornerRadius(20)
                                            .shadow(radius: 5)
                                            .rotation3DEffect(
                                                rotation,
                                                axis: (x: 0, y: 1, z: 0),
                                                anchor: .center,
                                                perspective: 0.3
                                            )
                                            .onTapGesture {
                                                onImageTap?(index)
                                            }
                                    }
                                    .frame(width: cardWidth, height: 350)
                                    .scaleEffect(scale)
                                    .zIndex(Double(zIndex))
                                    .offset(x: offset)
                                    .animation(.easeInOut(duration: 0.2), value: scale)
                                    .animation(.easeInOut(duration: 0.2), value: opacity)
                                    .animation(.easeInOut(duration: 0.2), value: rotation)
                                }
                                .frame(width: cardWidth, height: 350)
                                .id(index)
                                
                                
                            }
                        }
                        
                        .padding(.horizontal, centerOffset)
                        .background(GeometryReader {
                            Color.clear.preference(
                                key: ViewOffsetKey.self,
                                value: -$0.frame(in: .named("scroll")).origin.x
                            )
                        })
                        
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ViewOffsetKey.self) { offset in
                        scrollOffset = offset
                        if !isDragging {
                            updateCurrentIndex(offset: offset, cardWidth: cardWidth, spacing: spacing)
                        }
                    }
                    .onChange(of: internalIndex) { oldValue, newValue in
                        if !isDragging {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(newValue, anchor: .center)
                            }
                        }
                    }
                    
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { _ in
                                isDragging = true
                            }
                            .onEnded { value in
                                isDragging = false
                                let velocity = value.predictedEndTranslation.width - value.translation.width
                                let shouldUsePredictedEnd = abs(velocity) > 100
                                
                                let targetOffset = shouldUsePredictedEnd ?
                                scrollOffset + value.predictedEndTranslation.width :
                                scrollOffset + value.translation.width
                                
                                let targetIndex = Int(round(targetOffset / totalCardWidth))
                                let clampedIndex = min(max(targetIndex, 0), images.count - 1)
                                
                                if clampedIndex != internalIndex {
                                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                                        internalIndex = clampedIndex
                                        proxy.scrollTo(clampedIndex, anchor: .center)
                                        currentIndex = internalIndex
                                    }
                                }
                            }
                    )
                }
            }
        }
    }
    
    private func calculateRotation(distance: CGFloat) -> Angle {
        let maxRotation: Double = 35
        return .degrees(Double(distance) * maxRotation)
    }
    
    private func calculateOffset(distance: CGFloat) -> CGFloat {
        return distance * 5
    }
    
    private func updateCurrentIndex(offset: CGFloat, cardWidth: CGFloat, spacing: CGFloat) {
        let totalWidth = cardWidth + spacing
        let calculatedIndex = Int(round(offset / totalWidth))
        let clampedIndex = min(max(calculatedIndex, 0), images.count - 1)
        
        if clampedIndex != internalIndex {
            currentIndex = clampedIndex
            internalIndex = clampedIndex
        }
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
// MARK: - Preview
struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        let images = [
            "https://image.tmdb.org/t/p/w780/yvirUYrva23IudARHn3mMGVxWqM.jpg",
            "https://image.tmdb.org/t/p/w780/ombsmhYUqR4qqOLOxAyr5V8hbyv.jpg",
            "https://image.tmdb.org/t/p/w780/1RICxzeoNCAO5NpcRMIgg1XT6fm.jpg",
            "https://image.tmdb.org/t/p/w780/3YtZHtXPNG5AleisgEatEfZOT2w.jpg",
            "https://image.tmdb.org/t/p/w780/8SdaetXSTPyQVDb5pTEPRLBSx15.jpg"
        ]
        @State var currentIndex = 3
        
        CarouselView(images: images,currentIndex: $currentIndex,onImageTap: { index in
            print("Tapped image at index: \(index)")
            // Example: navigate, show alert, open detail view...
        })
    }
}
