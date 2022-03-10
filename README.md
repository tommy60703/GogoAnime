# GogoAnime - Gogolook iOS interview homework

## System Requirements

本專案使用 Xcode 13.2.1 和 Swift 5.5.2 開發，deplyment target 為 iOS 15.2。

## App 使用說明
### Top Anime/Manga 瀏覽
1. 在 app 首頁，選擇瀏覽 anime 或是 manga。
2. 選擇 anime/manga 之後，選擇該類型的 subtype 或全部內容。
3. 瀏覽該符合類型（和子分類）的項目列表。
4. 在列表中，可以點擊愛心圖標將喜愛的項目加到最愛或自最愛移除。

### 我的最愛列表
1. 在 app 首頁，選擇瀏覽 My Favorites。
2. 列表項目向左滑會出現自最愛移除的選項。

---

## System Design

GogoAnime 遵從 clean architecture 的原則，採用 repository pattern 和 use case pattern 以維持各單元之間的解耦合和可測試性。
UI 的部分採用 MVVM pattern 處理畫面與業務邏輯的溝通。

### Domain

在 `Domain` 資料夾中有關於 model、reposotory 和 use case 的定義，其中 repository 和 use case 皆為 protocol，具體實作細節則交給實作端處理。

```swift
/// Model
struct AnimeItem: Equatable, Hashable, Codable {
    // ...
}

/// Repository
protocol TopAnimeItemRepository {
    // ...
}

protocol FavoriteAnimeItemRepository {
    // ...
}

/// UseCase
protocol AnimeItemUseCase {
    // ...
}
```

Protocol `UseCaseFacotry` 用來將 use case 的依賴與行為本身分離，具體依賴哪些 repository 或服務，只需要在 compose 時知道就好。

```swift
/// UseCase factory
protocol UseCaseFactory {
    func makeAnimeItemUseCase() -> AnimeItemUseCase
}

/// 具體實作
final class AppUseCaseFactory: UseCaseFactory {
    
    private let animeItemRepo: TopAnimeItemRepository = MyAnimeListAnimeItemRepository()
    private let favoriteAnimeItemRepo: FavoriteAnimeItemRepository = LocalFavoriteAnimeItemRepository()
    
    func makeAnimeItemUseCase() -> AnimeItemUseCase {
        AppAnimeItemUseCase(animeItemRepo: animeItemRepo, favoriteItemRepo: favoriteAnimeItemRepo)
    }
}
```

### Services

兩個 Service 資料夾內是 repository 的具體實作，由於 GogoAnime 部分功能串接 API、另一部分存放於 local storage，這邊被分為 `MyAnimeListAnimeItemRepository` 負責和 My Anime List API 溝通、和 `LocalFavoriteAnimeItemRepository` 負責本機端資料存取。

```swift
/// 和 API 溝通取得 anime 列表
class MyAnimeListAnimeItemRepository: TopAnimeItemRepository { 
    // ...
}

// 本機端保存 favorite animes
class LocalFavoriteAnimeItemRepository: FavoriteAnimeItemRepository {
    // ...
} 
```

Architecture 示意圖
![GogoAnime](https://user-images.githubusercontent.com/4545214/157668655-d2c9b78e-289b-47e1-b2ce-7bbd354ca575.jpg)

### Coordinator

為達成 view controller 之間的解耦，使用 coordinator pattern 處理畫面流程。

```swift
final class AppCoordinator {
    // ...

    func start()
    func navigateToAnimeItemSubtypeList(animeItemType: AnimeItemType)
    func navigateToAnimeItemList(animeItemType: AnimeItemType, subtype: AnimeItemSubtype?)
    func navigateToFavoriteList()
    func presentAnimeItemDetail(url: URL)
}
```

---

## 技術選型
- 使用 Swift 5.5 提供之 async/await 功能處理非同步請求。
- ViewModel 和 functional reactive programming 的部分使用 Combine Framework。
- 列表使用 `DiffableDataSource` 與 `CellRegistration` 實作。
- 因資料簡單且較無安全性/隱私疑慮，persistent storage 暫時使用 `UserDefaults` 處理。
- Third party libraries 採用 Swift Package Manager 管理。
- 網路圖片請求使用 [Kinfisher](https://github.com/onevcat/Kingfisher)。

---

## Known Issues

已知在一些的情況下，MyAnimeList API 在不同 page 會存在相同 `mal_id` 的物件，由於目前列表的 diffable data source 使用 `mal_id` 作為 identifier，遇到這種情形會因為 identifier 不唯一而報錯閃退。

**解決方法**：詳見 Future Works。

## Future Works
### 預先處理不合理的 API 回傳值

可能的解法有以下幾種：

1. 在 `MyAnimeListAnimeItemRepository` 實作中，事先判斷相同 type 和 subtype 的不同分頁中，是否出現重複的 `mal_id`，若有重複的 `mal_id` 則將之剔除。
2. 在 diffable data source 中，透過 `mal_id`, `rank` 等多個欄位組合出唯一 identifier。
3. 不使用 diffable data source，改回傳統的 collection view data source 處理。

若 API 是由自身團隊維護，還可以：

4. 確保後端 API 保證 `mal_id` 的唯一性。
5. 改用 cursor based pagination，消除 page offset 問題。

### Better error handling

- 在 domain layer 定義 error type，實作時將遭遇的錯誤轉換成 domain error，將實作遇到的 error 隔離在實作層。
- 在 UI 層面提供錯誤發生的提示（例如 alert），本次因時間因素ˊ暫無實作。
- My Anime List API 回傳的 404 錯誤可能代表已無更多資料，應該 repository 或 use case 中作為正常情況處理。

### Framework 拆分與 access level 控制

將 Domain 和各個實作 service 拆分成獨立的 framework，並透過 access level 做到更好的抽象和封裝。（我目前在公司的專案即是採用這樣的方案。）

### 更完整的單元測試覆蓋率

盡可能測試所有單元的所有情況。