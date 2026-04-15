# IBStudy

Native **macOS** study app (SwiftUI) for IB/AP-style coursework: lessons, diagrams, flashcards, quizzes, glossary, and a local AI tutor via [Ollama](https://ollama.com).

## Build & run (developers)

```bash
swift build
swift run
# Or open the bundled IBStudy.app after syncing from .build/debug
```

Requires **macOS 14+**. See `AGENTS.md` for architecture and content layout.

## Website (download page)

The folder **`website/`** is a small **Next.js** site for a public download link and first-run hints. Deploy it on **Vercel** with root directory `website`.

**Full steps:** [docs/GITHUB_AND_VERCEL.md](docs/GITHUB_AND_VERCEL.md)

## License

Add a `LICENSE` file when you’re ready; not included here.
