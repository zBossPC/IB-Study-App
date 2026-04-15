import { Reveal } from "./components/Reveal";

/** Defaults match the public GitHub repo; override in Vercel if you fork. */
const DEFAULT_REPO = "https://github.com/zBossPC/IB-Study-App";
const DEFAULT_DOWNLOAD =
  "https://github.com/zBossPC/IB-Study-App/releases/download/v1.0.10/IBStudy-macos.dmg";

const downloadUrl =
  process.env.NEXT_PUBLIC_DOWNLOAD_URL?.trim() || DEFAULT_DOWNLOAD;
const repoUrl =
  process.env.NEXT_PUBLIC_GITHUB_REPO_URL?.trim() || DEFAULT_REPO;

export default function Home() {
  return (
    <>
      <div className="bg-mesh" aria-hidden />
      <div className="bg-grid" aria-hidden />

      <header className="nav">
        <div className="nav-inner">
          <a href="#" className="nav-brand">
            <span className="nav-brand-mark" aria-hidden>
              <img
                className="nav-mascot-img"
                src="/mascot.png"
                alt=""
                width={28}
                height={28}
                decoding="async"
              />
            </span>
            IBStudy
          </a>
          <nav className="nav-links" aria-label="Primary">
            <a href="#features">Features</a>
            <a href="#ai">AI tutor</a>
            <a href="#install">Install</a>
            <a href="#security">First launch</a>
            <a href={repoUrl} target="_blank" rel="noopener noreferrer">
              GitHub
            </a>
          </nav>
          <div className="nav-cta">
            <a
              className="btn btn-ghost"
              href={repoUrl}
              target="_blank"
              rel="noopener noreferrer"
            >
              View source
            </a>
            <a className="btn btn-primary" href={downloadUrl}>
              Download
            </a>
          </div>
        </div>
      </header>

      <main>
        <section className="hero wrap">
          <div className="hero-badge-row">
            <span className="hero-badge">v1.0.10</span>
            <span className="hero-badge-sub">Local AI that actually fits your Mac</span>
          </div>

          <div className="hero-split">
            <div className="hero-mascot">
              <img
                className="hero-mascot-img"
                src="/mascot.png"
                alt="IBStudy mascot — your in-app AI tutor"
                width={320}
                height={200}
                decoding="async"
                fetchPriority="high"
              />
            </div>
            <div className="hero-copy">
              <p className="hero-kicker">
                Lessons, drills, and progress tracking—built for long study sessions on your Mac.
                The same mascot cheers you on in the app and in the AI tutor.
              </p>
              <h1>
                <span className="hero-gradient">Study smarter</span>
                <br />
                on your Mac.
              </h1>
              <p className="hero-lead">
                Interactive lessons, diagrams, flashcards, quizzes, and a searchable glossary—plus
                optional <strong>local</strong> AI (Gemma 4 e2b via Ollama) that knows what lesson
                you&apos;re on. No API key. Privacy-first.
              </p>
              <div className="hero-actions">
                <a className="btn btn-primary btn-lg" href={downloadUrl}>
                  Download for macOS
                </a>
                <a
                  className="btn btn-ghost btn-lg"
                  href={`${repoUrl}/releases/tag/v1.0.10`}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Release notes
                </a>
              </div>
              <div className="hero-meta">
                <span>
                  <strong style={{ color: "var(--text-muted)" }}>macOS 26+</strong>
                  &nbsp;(Tahoe) · Apple Silicon & Intel
                </span>
                <span>Unsigned DMG · Friends &amp; beta</span>
                <span>Ollama optional · AI runs on-device</span>
              </div>
            </div>
          </div>

          <div className="preview">
            <div className="preview-chrome">
              <span className="preview-dot" />
              <span className="preview-dot" />
              <span className="preview-dot" />
              <span className="preview-title">IBStudy</span>
            </div>
            <div className="preview-body">
              <p className="preview-kicker">What you get</p>
              <h2>Everything in one focused workspace</h2>
              <p>
                Pick a subject, follow the path from lessons to review and challenge modes, and
                track progress with XP and streaks—without leaving the app.
              </p>
              <div className="preview-rows">
                <div className="preview-row">
                  <span className="preview-icon" aria-hidden>
                    📚
                  </span>
                  <span>
                    <strong>Learn</strong> — Markdown lessons with interactive diagrams where it
                    matters.
                  </span>
                </div>
                <div className="preview-row">
                  <span className="preview-icon" aria-hidden>
                    🃏
                  </span>
                  <span>
                    <strong>Review &amp; challenge</strong> — Flashcards and quizzes with feedback
                    tuned for exam prep.
                  </span>
                </div>
                <div className="preview-row">
                  <span className="preview-icon" aria-hidden>
                    ✨
                  </span>
                  <span>
                    <strong>AI tutor</strong> — The mascot-guided coach runs locally via Ollama;
                    your prompts stay on your machine.
                  </span>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section id="features" className="section wrap">
          <Reveal>
            <div className="section-head">
              <p className="section-kicker">Features</p>
              <h2>Built for serious study sessions</h2>
              <p>
                A calm, game-inspired interface that keeps you in flow—without turning your desktop
                into a game show.
              </p>
            </div>
          </Reveal>
          <Reveal>
            <div className="grid grid-3">
              <article className="card">
                <div className="card-icon" aria-hidden>
                  📖
                </div>
                <h3>Structured units</h3>
                <p>
                  Economics and physics content organized into clear stages with checkpoints so you
                  always know what&apos;s next.
                </p>
              </article>
              <article className="card">
                <div className="card-icon" aria-hidden>
                  📈
                </div>
                <h3>Interactive diagrams</h3>
                <p>
                  Explore microeconomics graphs with sliders and labels that match textbook
                  intuition—right inside the lesson.
                </p>
              </article>
              <article className="card">
                <div className="card-icon" aria-hidden>
                  🎯
                </div>
                <h3>XP &amp; streaks</h3>
                <p>
                  Light gamification: earn XP, keep a streak, and see your stage status without
                  noisy distractions.
                </p>
              </article>
              <article className="card">
                <div className="card-icon" aria-hidden>
                  🔍
                </div>
                <h3>Glossary</h3>
                <p>
                  Searchable definitions so you can jump from “what does this mean?” back to
                  practice in seconds.
                </p>
              </article>
              <article className="card">
                <div className="card-icon" aria-hidden>
                  🤖
                </div>
                <h3>Local AI coach</h3>
                <p>
                  Optional Ollama + Gemma 4 e2b: fast on Apple Silicon, context-aware, and your data
                  stays on your Mac.
                </p>
              </article>
              <article className="card">
                <div className="card-icon" aria-hidden>
                  🪟
                </div>
                <h3>Menu bar companion</h3>
                <p>
                  Quick access from the menu bar when you want a fast question without breaking
                  focus.
                </p>
              </article>
            </div>
          </Reveal>
        </section>

        <section id="ai" className="section wrap ai-section">
          <Reveal>
            <div className="section-head">
              <p className="section-kicker">v1.0.10</p>
              <h2>AI that matches the app—not a generic chatbot</h2>
              <p>
                The same mascot you see on lessons and quizzes appears in the tutor. Setup walks you
                through Ollama and pulls a compact Gemma 4 model so explanations feel snappy on
                everyday Macs.
              </p>
            </div>
          </Reveal>
          <Reveal>
            <div className="ai-showcase">
              <div className="ai-showcase-visual">
                <img
                  className="ai-showcase-mascot"
                  src="/mascot.png"
                  alt=""
                  width={280}
                  height={175}
                  decoding="async"
                />
              </div>
              <ul className="ai-points">
                <li>
                  <strong>Context-aware</strong> — The tutor knows your current subject, section,
                  and lesson when you ask.
                </li>
                <li>
                  <strong>Private by design</strong> — After install, inference runs locally. No
                  cloud API, no subscription.
                </li>
                <li>
                  <strong>Gemma 4 e2b</strong> — Tuned as the default for a lighter footprint; you
                  can switch models in-app if you prefer.
                </li>
                <li>
                  <strong>Floating window + menu bar</strong> — ⌘/ for the full tutor, or a compact
                  chip from the menu bar when you&apos;re heads-down.
                </li>
              </ul>
            </div>
          </Reveal>
        </section>

        <section id="install" className="section wrap">
          <Reveal>
            <div className="section-head">
              <p className="section-kicker">Install</p>
              <h2>Three steps to get running</h2>
              <p>Designed for friends testing the DMG—no Mac App Store required.</p>
            </div>
          </Reveal>
          <Reveal>
            <div className="steps">
              <div className="step">
                <div className="step-num">1</div>
                <div>
                  <h3>Download the DMG</h3>
                  <p>
                    Grab the latest <code>IBStudy-macos.dmg</code> from the release page. File size
                    is modest; use Wi‑Fi if you&apos;re on a slow link.
                  </p>
                </div>
              </div>
              <div className="step">
                <div className="step-num">2</div>
                <div>
                  <h3>Open the disk image</h3>
                  <p>
                    Double-click the DMG, then drag <strong>IBStudy.app</strong> to the Applications
                    shortcut—or into your Applications folder.
                  </p>
                </div>
              </div>
              <div className="step">
                <div className="step-num">3</div>
                <div>
                  <h3>Launch from Applications</h3>
                  <p>
                    Open IBStudy from Launchpad or Finder. On first run, macOS may warn you because
                    the app is unsigned—see &quot;First launch&quot; below.
                  </p>
                </div>
              </div>
            </div>
          </Reveal>
        </section>

        <section id="security" className="section wrap">
          <Reveal>
            <div className="section-head">
              <p className="section-kicker">First launch</p>
              <h2>Unsigned build &amp; Gatekeeper</h2>
              <p>
                This distribution is not notarized. That keeps costs at zero and is fine for
                friends—you just need one extra click the first time.
              </p>
            </div>
          </Reveal>
          <Reveal>
            <div className="callout">
              <h3>
                <span aria-hidden>⚠️</span> If macOS blocks the app
              </h3>
              <p>
                Right-click <strong>IBStudy.app</strong> in Finder → <strong>Open</strong> →
                confirm <strong>Open</strong> again. Alternatively, open <strong>System Settings</strong>{" "}
                → <strong>Privacy &amp; Security</strong> and allow the app when macOS lists it
                there.
              </p>
              <p className="callout-note">
                For a wider public release later, Apple&apos;s Developer Program (~$99/year) enables
                signing and notarization so Gatekeeper is much quieter. Optional for private sharing.
              </p>
            </div>
          </Reveal>
        </section>

        <section className="section wrap">
          <Reveal>
            <div className="cta-band">
              <div className="cta-mascot-wrap" aria-hidden>
                <img
                  className="cta-mascot"
                  src="/mascot.png"
                  alt=""
                  width={120}
                  height={75}
                  decoding="async"
                />
              </div>
              <div className="cta-copy">
                <h2>Ready to download?</h2>
                <p>
                  v1.0.10 — download for macOS Tahoe (26+). Questions? Open an issue on GitHub.
                </p>
                <a className="btn btn-primary btn-lg" href={downloadUrl}>
                  Download IBStudy
                </a>
              </div>
            </div>
          </Reveal>
        </section>

        <footer className="footer wrap">
          <div className="footer-grid">
            <div>
              <div className="footer-brand">
                <img
                  className="footer-mascot"
                  src="/mascot.png"
                  alt=""
                  width={36}
                  height={36}
                  decoding="async"
                />
                IBStudy
              </div>
              <p style={{ maxWidth: 280 }}>
                A native macOS study companion for rigorous coursework. Built for focus, practice,
                and optional local AI—with a mascot that stays with you in every mode.
              </p>
            </div>
            <div className="footer-col">
              <strong style={{ color: "var(--text)", fontSize: "0.8125rem" }}>Product</strong>
              <a href={downloadUrl}>Download</a>
              <a href={`${repoUrl}/releases`} target="_blank" rel="noopener noreferrer">
                Releases
              </a>
              <a href="#features">Features</a>
              <a href="#ai">AI tutor</a>
            </div>
            <div className="footer-col">
              <strong style={{ color: "var(--text)", fontSize: "0.8125rem" }}>Repository</strong>
              <a href={repoUrl} target="_blank" rel="noopener noreferrer">
                GitHub
              </a>
              <a href={`${repoUrl}/releases/tag/v1.0.10`} target="_blank" rel="noopener noreferrer">
                v1.0.10 notes
              </a>
            </div>
          </div>
          <p className="footer-disclaimer">
            IBStudy is an independent project and is not affiliated with or endorsed by the
            International Baccalaureate Organization. IB is a registered trademark of the
            International Baccalaureate Organization.
          </p>
        </footer>
      </main>
    </>
  );
}
