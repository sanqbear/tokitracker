# Home Screen Analysis - Legacy Android App

This document provides a comprehensive analysis of the legacy Android app's home screen structure to guide the Flutter implementation.

## Overview

The legacy app uses a tabbed interface with two main modes:
- **만화 (Comic)** - MainAdapter
- **웹툰 (Webtoon)** - MainWebtoonAdapter

## Core Data Structures

### Base Classes

#### MTitle (Minimal Title)
Base class for manga/webtoon titles with minimal information.

**Fields:**
```java
String name;           // Title name
int id;                // Unique identifier
String thumb;          // Thumbnail URL
String author;         // Author name
List<String> tags;     // Genre/category tags
String release;        // Release type (주간, 월간, 완결, etc.)
String path;           // Local file path (for offline)
int baseMode;          // base_comic (1) or base_webtoon (2)
```

**Constants:**
- `base_auto = 0`
- `base_comic = 1` - Maps to "/comic" URL
- `base_webtoon = 2` - Maps to "/webtoon" URL

#### Title (Full Title) extends MTitle
Extended class with episode list and bookmark functionality.

**Additional Fields:**
```java
List<Manga> eps;          // List of episodes
int bookmark;             // Bookmark position
Boolean bookmarked;       // Is bookmarked by user
String bookmarkLink;      // Bookmark API endpoint
int rc;                   // Recommendation count
```

**Key Methods:**
- `fetchEps(CustomHttpClient)` - Fetches episode list from `/{baseMode}/{id}`
- `toggleBookmark()` - Toggles bookmark status via API
- `isNew()` - Checks if title has "NEW" tag

#### Manga (Episode)
Represents a single manga/webtoon episode.

**Fields:**
```java
int id;                      // Episode ID
String name;                 // Episode name
String date;                 // Publication date
List<Manga> eps;             // Sibling episodes
List<String> imgs;           // Image URLs for pages
List<Comment> comments;      // User comments
List<Comment> bcomments;     // Best comments
String thumb;                // Thumbnail URL
Title title;                 // Parent title
int seed;                    // Random seed
int mode;                    // 0=online, 1-4=offline modes
String offlinePath;          // Local storage path
Manga nextEp, prevEp;        // Episode navigation
int baseMode;                // Inherited from title
```

**Key Methods:**
- `fetch(CustomHttpClient)` - Fetches episode details from `/{baseMode}/{id}`
- `getUrl()` - Returns `/{baseMode}/{id}`
- `nextEp()` / `prevEp()` - Episode navigation

#### Ranking&lt;E&gt; extends ArrayList&lt;E&gt;
Generic container for ranked lists with a name.

**Fields:**
```java
String name;  // Section name (e.g., "일반연재 최신")
```

Used to group ranked items (titles, mangas, or search terms).

---

## Comic Tab (MainAdapter)

### API Endpoint
- **URL:** `{baseUrl}/` (root)
- **Method:** GET
- **Parser:** JSoup HTML parsing

### Data Structure (MainPage.java)

```java
List<Manga> recent;              // Recently added manga
List<RankingTitle> ranking;      // Best ranking titles
List<RankingManga> weeklyRanking; // Weekly best manga
```

**Subclasses:**
- `RankingTitle extends Title` - Adds `int ranking` field
- `RankingManga extends Manga` - Adds `int ranking` field

### UI Sections (MainAdapter.java)

The adapter displays data in the following sections:

1. **최근 추가된 만화 (Recently Added Manga)**
   - Header with "더 보기" (More) button
   - Data: Updated manga list (placeholder for real-time updates)
   - Click action: `clickedMoreUpdated()`

2. **북마크 업데이트 (Bookmark Updates)**
   - Header
   - Data: User's bookmarked titles with new episodes
   - Click action: `clickedTitle(Title)`

3. **최근에 본 만화 (Recently Viewed)**
   - Header
   - Data: User's viewing history
   - Click action: `clickedTitle(Title)` or `clickedManga(Manga)`

4. **주간 베스트 (Weekly Best)**
   - Header
   - Data: `weeklyRanking` (RankingManga with position numbers)
   - Click action: `clickedManga(Manga)`

5. **일본만화 베스트 (Japanese Manga Best)**
   - Header
   - Data: `ranking` (RankingTitle with position numbers)
   - Click action: `clickedTitle(Title)`

6. **Tag Sections**
   - Name tags (작가 태그)
   - Genre tags (장르 태그)
   - Release tags (발행구분 태그)
   - Click action: `clickedTag(String)`

### Parsing Logic (MainPage.java)

```java
// 1. Recent manga - from first div.miso-post-gallery
for (Element e : d.selectFirst("div.miso-post-gallery").select("div.post-row")) {
    id = Integer.parseInt(e.selectFirst("a").attr("href").split("comic/")[1]);
    name = e.selectFirst("div.post-subject").ownText();
    thumb = e.selectFirst("img").attr("data-src");
    // ... parse date, tags, author, release
    recent.add(new Manga(id, name, date, base_comic));
}

// 2. Ranking titles - from last div.miso-post-gallery
for (Element e : d.select("div.miso-post-gallery").last().select("div.post-row")) {
    // Similar parsing with ranking number
    ranking.add(new RankingTitle(..., rankingNum));
}

// 3. Weekly ranking - from last div.miso-post-list
for (Element e : d.select("div.miso-post-list").last().select("li.post-row")) {
    // Parse manga with ranking
    weeklyRanking.add(new RankingManga(..., rankingNum));
}
```

---

## Webtoon Tab (MainWebtoonAdapter)

### API Endpoint
- **URL:** `/site.php?id=1` (redirects to actual webtoon site)
- **Method:** GET
- **Parser:** JSoup HTML parsing

### Data Structure (MainPageWebtoon.java)

```java
List<Ranking<?>> dataSet;  // 8 ranking sections
```

**Sections (in order):**
1. 일반연재 최신 (Normal New)
2. 성인웹툰 최신 (Adult New)
3. BL/GL 최신 (Gay New)
4. 일본만화 최신 (Comic New)
5. 일반연재 베스트 (Normal Best)
6. 성인웹툰 베스트 (Adult Best)
7. BL/GL 베스트 (Gay Best)
8. 일본만화 베스트 (Comic Best)

### Parsing Logic (MainPageWebtoon.java)

```java
// Get actual webtoon URL via redirect
Response r = client.mget("/site.php?id=1");
if (r.code() == 302) {
    baseUrl = r.header("Location");  // Extract manatoki URL
}

// Fetch webtoon page
Response r2 = client.get(baseUrl, null);
Document d = Jsoup.parse(r2.body().string());
Elements boxes = d.select("div.main-box");

// Parse each section (boxes index: nn=4, an=5, gn=6, cn=7, nb=8, ab=9, gb=10, cb=11)
parseTitle("일반연재 최신", boxes.get(4).select("a"), base_webtoon);
parseTitle("성인웹툰 최신", boxes.get(5).select("a"), base_webtoon);
// ... etc
```

**parseTitle method:**
```java
for (Element e : es) {
    name = e.selectFirst("div.in-subject").ownText();  // or e.ownText()
    id = Integer.parseInt(idString.substring(...));    // Extract from href
    tmp = new Title(name, "", "", null, "", id, baseMode);
    ranking.add(tmp);
}
```

---

## Key Differences: Comic vs Webtoon

| Aspect | Comic Tab | Webtoon Tab |
|--------|-----------|-------------|
| **Data Source** | Main site root | Separate webtoon site via redirect |
| **Data Types** | Mixed (Manga, Title, Tags) | Titles only |
| **Sections** | 6+ dynamic sections | 8 fixed ranking sections |
| **Personalization** | Bookmarks, history | None (all rankings) |
| **Layout** | Complex (grid, list, tags) | Simple (8 ranked lists) |
| **Base Mode** | `base_comic` | `base_webtoon` or `base_comic` (for 일본만화) |

---

## Navigation Flow

### From Home Screen

**Comic Tab:**
- Click Title → Navigate to Title Detail (episode list)
- Click Manga → Navigate to Episode Viewer (image pages)
- Click Tag → Navigate to Tag Search Results
- Click "더 보기" → Navigate to Updated Manga List

**Webtoon Tab:**
- Click Title → Navigate to Title Detail (episode list)

### Title Detail Page
- Fetches from `/{baseMode}/{id}`
- Displays episode list, bookmark button, recommend count
- User can select episode to view

### Episode Viewer
- Fetches from `/{baseMode}/{id}` (same as title, but for specific episode)
- Displays image pages, comments
- Navigation to next/previous episode

---

## API Patterns

### Base URL
- Configurable via LocalStorage (`getBaseUrl()`)
- Example: `https://manatoki123.net`

### Endpoints

| Purpose | Endpoint | Method | Response |
|---------|----------|--------|----------|
| Comic home | `/` | GET | HTML |
| Webtoon redirect | `/site.php?id=1` | GET | 302 redirect |
| Webtoon home | `{redirect URL}` | GET | HTML |
| Title detail | `/{comic\|webtoon}/{id}` | GET | HTML |
| Episode detail | `/{comic\|webtoon}/{id}` | GET | HTML |
| Toggle bookmark | `{bookmarkLink}` | POST | JSON |

### HTML Selectors

**Comic Home:**
- Recent manga: `div.miso-post-gallery:first > div.post-row`
- Ranking titles: `div.miso-post-gallery:last > div.post-row`
- Weekly ranking: `div.miso-post-list:last > li.post-row`

**Webtoon Home:**
- Main boxes: `div.main-box` (indices 4-11)
- Title links: `a` (within each box)

**Title Detail:**
- Title: `div.view-title > div.view-content > b`
- Thumbnail: `div.view-img > img`
- Author: Strong "작가" → `a`
- Tags: Strong "분류" → `a[]`
- Release: Strong "발행구분" → `a`
- Episodes: `ul.list-body > li.list-item`
- Bookmark: `a#webtoon_bookmark`
- Recommend: `button.btn-red > b`

**Episode Detail:**
- Episode name: `div.toon-title`
- Images: Encoded in `script` tag, decoded with URLDecoder
- Comments: `section#bo_vc > div.media`
- Best comments: `section#bo_vcb > div.media`
- Episode selector: `div.toon-nav > select > option`

---

## State Management

### Data Fetching
- Uses `AsyncTask` for background fetching
- Shows loading state during fetch
- Handles captcha redirects (302 to `captcha.php`)
- Retries on adblock connection timeout

### User Data
- Bookmarks (requires login)
- Viewing history
- Login session via cookies

### Offline Support
- Downloaded episodes stored locally
- Modes: 0=online, 1=old offline, 2=moa offline, 3=toki offline, 4=new moa offline

---

## Implementation Notes for Flutter

### Required Domain Entities

1. **BaseMode enum**
   - auto, comic, webtoon

2. **MangaTitle** (equivalent to MTitle)
   - id, name, thumb, author, tags, release, baseMode

3. **TitleDetail** (equivalent to Title)
   - Extends MangaTitle
   - episodes, bookmark, bookmarked, recommendCount

4. **Episode** (equivalent to Manga)
   - id, name, date, baseMode
   - For list display only (no images/comments)

5. **EpisodeDetail** (equivalent to full Manga)
   - Extends Episode
   - images, comments, siblingEpisodes

6. **RankedItem&lt;T&gt;**
   - item: T
   - ranking: int

7. **RankingSection&lt;T&gt;**
   - name: String
   - items: List&lt;RankedItem&lt;T&gt;&gt;

### Required Use Cases

**Comic Tab:**
- `FetchComicHomeData()` → ComicHomeData
  - recentManga: List&lt;Episode&gt;
  - rankingTitles: List&lt;RankedItem&lt;MangaTitle&gt;&gt;
  - weeklyRanking: List&lt;RankedItem&lt;Episode&gt;&gt;
  - (bookmark/history data can be added later)

**Webtoon Tab:**
- `FetchWebtoonHomeData()` → WebtoonHomeData
  - sections: List&lt;RankingSection&lt;MangaTitle&gt;&gt; (8 sections)

**Common:**
- `FetchTitleDetail(titleId, baseMode)` → TitleDetail
- `FetchEpisodeDetail(episodeId, baseMode)` → EpisodeDetail
- `ToggleBookmark(titleId, baseMode)` → bool

### Required Data Sources

**Remote:**
- `HomeRemoteDataSource`
  - `fetchComicHome()` → parse HTML with html package
  - `fetchWebtoonHome()` → parse HTML with html package

**Local (for later):**
- `BookmarkLocalDataSource`
- `HistoryLocalDataSource`

### UI Components

**Comic Tab:**
- Section header (with optional "더 보기" button)
- Horizontal manga list (recent)
- Vertical ranked list (weekly best)
- Tag cloud (name, genre, release)

**Webtoon Tab:**
- 8 vertical sections with headers
- Ranked title lists (position + name)

**Common:**
- Title card (thumbnail, name, author, tags)
- Episode card (name, date)
- Loading skeleton
- Error retry widget

---

## Next Steps

1. ✅ Complete legacy app analysis
2. ⏭️ Design Flutter domain entities
3. ⏭️ Design repository interfaces
4. ⏭️ Implement data models with json_serializable
5. ⏭️ Implement data sources (HTML parsing)
6. ⏭️ Implement repositories
7. ⏭️ Implement use cases
8. ⏭️ Implement BLoC (states, events, logic)
9. ⏭️ Implement UI widgets
10. ⏭️ Implement pages (ComicTab, WebtoonTab)
11. ⏭️ Integrate with existing app (HomePage with tabs)
