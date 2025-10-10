# Title Detail Screen Analysis

## Overview
Analysis of the legacy Android app's title detail screen (EpisodeActivity) to understand its structure and functionality for Flutter implementation.

## Legacy Implementation

### EpisodeActivity.java
**Location**: `references/MangaViewAndroid/app/src/main/java/ml/melun/mangaview/activity/EpisodeActivity.java`

**Purpose**: Displays detailed information about a manga/webtoon title and lists all available episodes.

### Key Components

#### 1. Data Model - Title.java
**Location**: `references/MangaViewAndroid/app/src/main/java/ml/melun/mangaview/mangaview/Title.java`

**Properties**:
```java
class Title extends MTitle {
    private List<Manga> eps;           // Episode list
    int bookmark;                      // Current bookmark episode ID
    Boolean bookmarked;                // Server-side bookmark status
    String bookmarkLink;               // Bookmark toggle API URL
    int rc;                            // Recommend count
}
```

**Key Methods**:
- `fetchEps(CustomHttpClient client)` - Fetches episode list and title details from server
  - Returns `LOAD_OK` (0) or `LOAD_CAPTCHA` (1)
  - Parses HTML to extract:
    - Title name
    - Thumbnail
    - Author
    - Tags (genres)
    - Release status
    - Recommend count
    - Bookmark status
    - Episode list

- `toggleBookmark(CustomHttpClient client, Preference p)` - Toggles server-side bookmark

#### 2. HTML Parsing Structure

**URL Pattern**: `/{baseMode}/{id}`
- Example: `/comic/23979554` or `/webtoon/12345`

**HTML Selectors**:
```java
// Title Header
Document d = Jsoup.parse(body);
Element header = d.selectFirst("div.view-title");

// Extra Info Table
Element infoTable = d.selectFirst("table.table");
- rc (recommend count): infoTable.selectFirst("button.btn-red").selectFirst("b").ownText()
- bookmark: infoTable.selectFirst("a#webtoon_bookmark")
  - bookmarked = bookmark.hasClass("btn-orangered")
  - bookmarkLink = bookmark.attr("href")

// Thumbnail
thumb = header.selectFirst("div.view-img").selectFirst("img").attr("src")

// Content
Elements infos = header.select("div.view-content");
- name: infos.get(1).selectFirst("b").ownText()
- Loop through infos to find:
  - "작가" (Author): e.selectFirst("a").ownText()
  - "분류" (Tags): e.select("a") -> collect ownText()
  - "발행구분" (Release): e.selectFirst("a").ownText()

// Episodes
for (Element e : d.selectFirst("ul.list-body").select("li.list-item")) {
    Element titlee = e.selectFirst("a.item-subject");
    id = getNumberFromString(titlee.attr("href").split(baseModeStr(baseMode) + '/')[1]);
    title = titlee.ownText();

    Elements infoe = e.selectFirst("div.item-details").select("span");
    date = infoe.get(0).ownText();

    eps.add(new Manga(id, title, date, baseMode));
}
```

#### 3. UI Structure - EpisodeAdapter.java

**Layout Types**:
1. **Header (position 0)** - Title information card
   - Layout: `R.layout.item_header`
   - Components:
     - Thumbnail image
     - Title name
     - Author (clickable - navigates to author search)
     - Release status
     - Tags (horizontal scrollable list, clickable)
     - Recommend count
     - Favorite button (star icon)
     - Bookmark button (bookmark icon, requires login)
     - "첫화보기" (View first episode) button

2. **Episode Items (position 1+)** - Episode list
   - Layout: `R.layout.item_episode`
   - Components:
     - Episode name
     - Upload date
     - Highlighted background if bookmarked
     - Click to open viewer

**Visual States**:
- Favorite toggle: Star icon filled/unfilled
- Bookmark toggle: Bookmark icon filled/unfilled
- Bookmarked episode: Highlighted background
- Login required: Bookmark disabled if not logged in

#### 4. User Interactions

**EpisodeActivity**:
- **Back Button**: Close activity
- **Download Menu**: Navigate to DownloadActivity
- **Resume FAB**: Jump to bookmarked episode and open viewer
- **Up FAB**: Scroll to top
- **Down FAB**: Scroll to bottom
- **Episode Click**: Open ViewerActivity

**Header (via EpisodeAdapter)**:
- **Bookmark Button Click**: Toggle server-side bookmark (requires login)
- **Star Button Click**: Toggle local favorite
- **First Button Click**: Open first episode in viewer
- **Author Click**: Navigate to TagSearchActivity with author query
- **Tag Click**: Navigate to TagSearchActivity with tag query

**Episode Item Click**:
- Highlight selected episode
- Open ViewerActivity with manga data

#### 5. Data Flow

```
Intent (from previous screen)
  ↓
  title (JSON string) → Gson.fromJson() → Title object
  online (boolean) → determines mode
  position (int) → list position (for result)
  favorite (boolean) → return favorite status to caller
  recent (boolean) → return recent status to caller
  ↓
EpisodeActivity.onCreate()
  ↓
  if (online) {
      getEpisodes AsyncTask
        ↓
        title.fetchEps(httpClient) → Parse HTML
        ↓
        episodes = title.getEps()
        ↓
        if (LOAD_CAPTCHA) → showCaptchaPopup
        else if (empty) → showCaptchaPopup
        else → afterLoad()
  } else {
      Load offline episodes from local storage
        ↓
        afterLoad()
  }
  ↓
afterLoad()
  ↓
  Set up EpisodeAdapter
  Set up click listeners
  Scroll to bookmark if exists
  Show/hide resume FAB based on bookmark
  ↓
User interactions:
  - Click episode → openViewer()
  - Click bookmark → ToggleBookmark AsyncTask
  - Click favorite → toggleFavorite() (local only)
  - Click author/tag → Navigate to search
  ↓
Result to caller:
  - favorite status
  - bookmark ID
```

#### 6. Mode System

**Modes**:
- `mode = 0`: Online mode (fetch from server)
- `mode = 1`: Offline mode (local storage, no title.gson)
- `mode = 3`: Offline mode (local storage with title.gson)
- `mode = 4`: Migrated offline mode (no bookmark support)

**Online Mode Features**:
- Fetch episodes from server
- Show recommend count
- Server-side bookmark toggle (requires login)
- Local favorite toggle
- Add to recent list

**Offline Mode Features**:
- Load episodes from local filesystem
- No server communication
- No bookmark toggle
- Local favorite only (if useBookmark)

#### 7. Navigation Targets

**From EpisodeActivity**:
- **ViewerActivity**: View manga episode
- **DownloadActivity**: Download episodes
- **TagSearchActivity**: Search by author or tag

**To EpisodeActivity**:
- **MainActivity**: Home screen item click
- **Search results**: Title search result click
- **Favorites**: Favorite list item click
- **Recent**: Recent list item click
- **History**: History list item click

## Key Features to Implement

### Must-Have Features (Phase 1)
1. ✅ Fetch title details from server
2. ✅ Display title information (name, author, thumbnail, tags, release)
3. ✅ Display episode list
4. ✅ Navigate to viewer on episode click
5. ✅ Local favorite toggle
6. ✅ Add to recent list
7. ✅ Error handling (captcha, network errors)

### Should-Have Features (Phase 2)
8. ⏳ Server-side bookmark toggle (requires login)
9. ⏳ Scroll to bookmarked episode
10. ⏳ Resume button to jump to bookmark
11. ⏳ "첫화보기" (View first episode) button
12. ⏳ Author click → navigate to search
13. ⏳ Tag click → navigate to search
14. ⏳ Recommend count display

### Nice-to-Have Features (Phase 3)
15. ⏳ Offline mode support
16. ⏳ Download menu
17. ⏳ Scroll to top/bottom FABs
18. ⏳ Episode highlight on selection
19. ⏳ Return result to caller (favorite/bookmark status)

## Data Models Needed

### TitleDetail Entity
```dart
class TitleDetail {
  final int id;
  final String name;
  final String? thumbnailUrl;
  final String? author;
  final List<String> tags;
  final String? release;
  final BaseMode baseMode;
  final List<Episode> episodes;
  final int recommendCount;
  final bool isBookmarked;
  final String bookmarkLink;
}
```

### Episode Entity
Already exists in home feature, can be reused:
```dart
class Episode {
  final int id;
  final String name;
  final String? date;
  final String? thumbnailUrl; // Not used in detail screen
  final BaseMode baseMode;
}
```

## API Endpoints

### Fetch Title Details
- **URL**: `{baseUrl}/{baseMode}/{id}`
- **Method**: GET
- **Response**: HTML page
- **Parse**:
  - Title info from `div.view-title`
  - Episodes from `ul.list-body > li.list-item`
  - Extra info from `table.table`

### Toggle Bookmark
- **URL**: Extracted from `a#webtoon_bookmark` href attribute
- **Method**: POST
- **Body**:
  ```
  mode: "on" | "off"
  top: "0"
  js: "on"
  ```
- **Headers**:
  ```
  Cookie: {session cookie}
  ```
- **Response**: JSON
  ```json
  {
    "error": "",
    "success": "message"
  }
  ```

## UI Components

### Header Section
- Thumbnail (large image)
- Title name (bold, large text)
- Author (clickable text)
- Release status (small text)
- Tags (horizontal chip list, clickable)
- Action buttons:
  - Favorite (star icon toggle)
  - Bookmark (bookmark icon toggle, login required)
  - "첫화보기" (primary button)
- Stats:
  - Recommend count (icon + number)

### Episode List Section
- Scrollable list
- Each item:
  - Episode name
  - Upload date
  - Background highlight if bookmarked
  - Ripple effect on touch

### Floating Action Buttons
- Resume button (visible only if bookmarked)
- Scroll up button
- Scroll down button

## State Management

### States
```dart
sealed class TitleDetailState {}
class TitleDetailInitial extends TitleDetailState {}
class TitleDetailLoading extends TitleDetailState {}
class TitleDetailLoaded extends TitleDetailState {
  final TitleDetail titleDetail;
  final bool isFavorite;
  final int? bookmarkedEpisodeId;
}
class TitleDetailError extends TitleDetailState {
  final String message;
}
class TitleDetailCaptchaRequired extends TitleDetailState {
  final String url;
}
```

### Events
```dart
sealed class TitleDetailEvent {}
class TitleDetailFetchRequested extends TitleDetailEvent {
  final int titleId;
  final BaseMode baseMode;
}
class TitleDetailFavoriteToggled extends TitleDetailEvent {}
class TitleDetailBookmarkToggled extends TitleDetailEvent {}
class TitleDetailRefreshRequested extends TitleDetailEvent {}
```

## Error Handling

### Captcha Detection
- HTTP 302 redirect to `captcha.php`
- Empty episode list after fetch
- Show captcha dialog/page

### Network Errors
- Connection timeout
- No response
- Show error message with retry option

### Login Required
- Bookmark toggle requires valid session
- Show login dialog if not logged in

## Notes

1. **Bookmark vs Favorite**:
   - Bookmark: Server-side, syncs across devices, requires login
   - Favorite: Local only, no login required, stored in SharedPreferences

2. **Episode Order**:
   - Episodes are ordered newest first (index 0 = latest episode)
   - "첫화보기" (first episode) = last item in list

3. **Bookmark Index**:
   - Stored as episode ID, not list position
   - Need to find index in episode list for UI highlight

4. **Offline Mode**:
   - For Phase 1, focus on online mode only
   - Offline mode can be added later

5. **Recent List**:
   - Add to recent list only after successful load
   - Update recent data with latest episode info

## Next Steps

1. Create TITLE_DETAIL_ARCHITECTURE.md with Flutter implementation design
2. Implement domain layer (entities, repository, use cases)
3. Implement data layer (models, data source, repository impl)
4. Implement presentation layer (BLoC, page, widgets)
5. Add navigation from home screen
6. Test with real data
