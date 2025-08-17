# 📷 MyMovie App

An iOS movie app built with **SwiftUI** and **RxSwift**, showcasing movie lists, ratings.
---



## 📸 Screenshots

### Home Screen
![Home](home.gif)


## 🛠 Architecture

- **UIKit + MVVM**
- **RxSwift / RxCocoa / RxRelay**
- **Moya** for API abstraction
---

## 📦 Dependencies

Using Swift Package Manager:

- [`RxSwift`](https://github.com/ReactiveX/RxSwift)
- [`RxCocoa`](https://github.com/ReactiveX/RxSwift)
- [`Moya`](https://github.com/Moya/Moya)
- [`Kingfisher`](https://github.com/onevcat/Kingfisher) *(optional: for image loading)*

> 🔥 No third-party UI layout libs used (staggered layout is fully custom).

---

## 🧪 RxSwift Highlights

- Data binding with `BehaviorRelay`
- `collectionView.rx.contentOffset` for infinite scroll
- Detail screen uses reactive data flow for UI updates


---
## 🚀 Getting Started
git clone https://github.com/naylinndev/MyMovieApp.git
cd MyMovieApp
open MyMovieApp.xcodeproj
Install SPM packages (RxSwift, Moya, Kingfisher)

Build and run!

