# IBStudy — Agent Memory

## Project Overview
**IBStudy** is a native macOS SwiftUI study app for IB/AP coursework. It supports multiple subjects with interactive lessons, diagrams, flashcards, quizzes, a glossary, and a local AI tutor powered by Ollama (Gemma 4).

- **Platform:** macOS 26+ (Tahoe) — SwiftUI, AppKit where needed
- **Build:** Swift Package Manager (Swift 6.2) — run `swift build` from project root
- **Run:** Open `IBStudy.app` (standalone bundle) or `swift run` from terminal
- **Project root:** `~/Documents/IBStudy`
- **Sources:** `Sources/IBStudy/`

---

## Current Subjects

| Subject | File | Sections |
|---|---|---|
| Economics — AP Unit 3 Microeconomics | `unit3.json` | production, short-run-costs, cost-revenue-profit, long-run-costs, perfect-competition, monopoly, monopolistic-competition |
| Physics — Static Electricity | `physics_static.json` | static-lesson1 (Electric Charge), static-lesson2 (Methods of Charging), static-lesson3 (Electric Force), static-lesson4 (Electric Fields) |

---

## Architecture

### Data Model (`Sources/IBStudy/Models/Unit3Models.swift`)
- `Subject` — top-level container with id, title, subtitle, icon (SF Symbol), color, and `UnitPayload`
- `UnitPayload` — unitId, title, sections[], glossary[]
- `ContentSection` — id, title, lessons[], flashcards[], questions[]
- `Lesson` — id, title, bodyMarkdown
- `Flashcard` — id, front, back
- `MCQuestion` — id, prompt, choices[], correctIndex, explanation
- `GlossaryTerm` — id, term, definition

### Services
- `ContentStore` — loads all subject JSON files; exposes `subjects: [Subject]` and `selectedSubjectId: String`. Backward-compatible `payload` computed var returns selected subject's payload.
- `ProgressStore` — UserDefaults persistence for XP, level, streak, quiz scores, flashcard mastery, achievements. Has `resetAll()` method.
- `OllamaSetupManager` — automated Ollama install (via Homebrew), `ollama serve`, model pull with progress. Model candidates: `gemma4:e2b`, `gemma4:e4b`, `gemma3:4b`
- `OllamaService` — HTTP streaming chat via `http://127.0.0.1:11434/api/chat`
- `StudyContext` — singleton that tracks the current subject/section/lesson the user is viewing; injected into AI system prompts for contextual responses
- `ThemeManager` — persists selected theme via `@AppStorage`; exposes `current: AppTheme` and `pageGradient`

### Views
- `RootView` — `NavigationSplitView` with collapsible sidebar (toggle button in toolbar), subject picker + section list; detail area switches on `SidebarSelection`
- `SectionDetailView` — tabbed view (Learn / Review / Challenge) for a section; updates `StudyContext` on appear
- `MarkdownLessonView` — block-based custom markdown renderer (headings, bullets, numbered lists, tables, callouts, code blocks)
- `EconDiagram.swift` — custom Canvas-drawn diagrams for economics (supply/demand, cost curves, etc.)
- `WelcomeDashboardView` — home screen with progress summary and quick-start cards
- `AITutorView` — floating window AI chat (opens via ⌘/ or toolbar); uses `NativeChatField` (NSTextView wrapper) for reliable macOS input; system prompt is context-aware via `StudyContext`
- `MenuBarAIView` — compact AI chat in system menu bar extra (sparkles icon); also context-aware
- `QuizSessionView` — quiz with hint button showing relevant diagrams
- `FlashcardStudyView` — flip cards with mastery tracking
- `GlossaryView` — searchable glossary
- `SettingsView` — theme picker (6 themes), preferences, data reset
- `AboutView` — detailed app info, version, credits, tech stack, legal
- `AccountsView` — placeholder "coming soon" page for future cloud sync

### Theme System
- `GlassTheme` — static section colors/icons/gradients, reusable glass panel modifiers
- `ThemeManager` — 6 built-in themes: Midnight (default), Ocean, Aurora, Ember, Lavender, Slate
- `AppTheme` — defines pageTop/pageBottom/pageMid colors, accentCore/accentGlow, panel opacity
- `PlayfieldBackground` — uses `ThemeManager` for dynamic gradient backgrounds
- `sectionColor(_:)` and `sectionIcon(_:)` map section IDs to colors/SF Symbols — update here when adding sections

### Navigation (`NavigationTypes.swift`)
```swift
enum SidebarSelection: Hashable {
    case home, glossary, aiTutor, settings, about, accounts, section(String)
}
```

---

## Adding a New Subject

1. Create `Sources/IBStudy/Resources/<name>.json` with `UnitPayload` structure (unitId, title, sections, glossary)
2. Add entry to the manifest array in `ContentStore.load()`
3. Add section color/icon cases to `GlassTheme.sectionColor(_:)` and `sectionIcon(_:)`
4. If diagrams needed, add cases to `EconDiagram.swift`

## Adding Diagrams for Physics

Physics lessons currently show text only. To add Canvas diagrams for physics topics:
- Add cases to `EconDiagram.swift` for diagram types: `coulombsLaw`, `electricFieldLines`, `chargingByInduction`, etc.
- Reference them in `SectionDetailView` via the existing `SectionDiagram` view (which maps section ID to diagram)

---

## AI Tutor

- **Model:** `gemma4:e2b` (Gemma 4 Efficient 2B, ~1.5 GB, lightweight on Apple Silicon)
- **Fallback chain:** `gemma4:e2b` → `gemma4:e4b` → `gemma3:4b`
- **Context:** `StudyContext.shared` tracks current subject/section/lesson and injects it into the system prompt so the AI knows what the student is studying
- **Setup:** `OllamaSetupManager.run()` auto-installs Homebrew → Ollama → pulls model on first launch
- **Ports:** `http://127.0.0.1:11434`
- **Input:** `NativeChatField` (NSTextView-based) — required for reliable focus in SPM-launched apps
- **Windows:** Main floating window (id: `ai-tutor`, ⌘/) + MenuBarExtra

---

## Build & Run

```bash
# Build
cd ~/Documents/IBStudy && swift build

# Run directly
.build/debug/IBStudy

# Or open the .app bundle
open IBStudy.app
```

## Auto-Rebuild Hook
`.cursor/hooks/rebuild-app.sh` triggers on every `.swift` file save — runs `swift build` in background and swaps the binary in `IBStudy.app`.

---

## Publishing a release

When you (or the user) want to **publish** the app: run **`./scripts/publish.sh --ship`** from the repo root. That builds the DMG, prints Sparkle `edSignature` / `length` for `docs/appcast.xml`, uploads the DMG to the matching GitHub release via `gh` (if installed), and runs `npm run build` in `website/`.

- **Manual pieces:** Add a new Sparkle `<item>` when the **build** number bumps; push so Vercel can deploy the site.
- **Scripts:** `scripts/build-dmg.sh`, `scripts/sign-release.sh`, `scripts/publish.sh`

---

## Known Issues / Notes
- `swift run` requires `NSApp.activate(ignoringOtherApps: true)` in `init()` to grab keyboard focus (already in place)
- Ollama `gemma4:e2b` — if setup fails, check `ollama serve` is running: `curl http://127.0.0.1:11434/api/tags`
- The build artifact is at `.build/debug/IBStudy` (debug) or `.build/release/IBStudy` (release)
- Physics sections use text-only lessons (no Canvas diagrams yet — planned)
- Accounts page is a placeholder — cloud sync not yet implemented
