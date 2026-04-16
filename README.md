# IBStudy

Native **macOS** study app (SwiftUI) for IB/AP-style coursework: lessons, diagrams, flashcards, quizzes, glossary, and a local AI tutor via [Ollama](https://ollama.com).

## Build & run (developers)

```bash
swift build
swift run
# Or open the bundled IBStudy.app after syncing from .build/debug
```

Requires **macOS 26+** (Tahoe). See `AGENTS.md` for architecture and content layout.

## Website (download page)

The folder **`website/`** is a small **Next.js** site for a public download link and first-run hints. Deploy it on **Vercel** with root directory `website`.

**Repository:** [github.com/zBossPC/IB-Study-App](https://github.com/zBossPC/IB-Study-App)  
**Releases / download:** [v1.0.14](https://github.com/zBossPC/IB-Study-App/releases/tag/v1.0.14) — local AI (Gemma 4 e2b), context-aware tutor, mascot, Ollama CWD fix. Get **`IBStudy-macos.dmg`** (unsigned; right-click → Open the first time).

**Build a DMG locally:** `./scripts/build-dmg.sh` (uses [create-dmg](https://github.com/create-dmg/create-dmg) if installed: `brew install create-dmg`).

**Full steps:** [docs/GITHUB_AND_VERCEL.md](docs/GITHUB_AND_VERCEL.md)

**Documents folder prompt:** If macOS asks for access to **Documents** on launch, it often means the app (or a dev build) is being run from a folder under `~/Documents/` (for example the project repo). Install **`IBStudy.app` into `/Applications`** and open it from there, or allow access once in **System Settings → Privacy & Security → Files and Folders**. The app also sets a neutral working directory for Ollama/brew subprocesses so they do not inherit that path.

## License

Add a `LICENSE` file when you’re ready; not included here.
