import Image from "next/image";
import Link from "next/link";
import { ProductShots } from "./components/ProductShots";
import { Reveal } from "./components/Reveal";
import { APP_VERSION, MACOS_CODENAME, MACOS_REQUIREMENT, RELEASE_TAG, downloadUrl, repoUrl } from "@/lib/site";

export default function Home() {
  return (
    <>
      <section className="hero wrap">
        <div className="hero-badge-row">
          <span className="hero-badge">v{APP_VERSION} · {MACOS_REQUIREMENT}</span>
          <span className="hero-badge-sub">Free · macOS {MACOS_CODENAME}+ · Apple Silicon & Intel</span>
        </div>

        <div className="hero-split">
          <div className="hero-mascot">
            <Image
              className="hero-mascot-img"
              src="/mascot.png"
              alt="IBStudy mascot"
              width={320}
              height={200}
              priority
            />
          </div>
          <div className="hero-copy">
            <h1>
              <span className="hero-gradient">Study smarter.</span>
              <br />
              Built for your Mac.
            </h1>
            <p className="hero-lead">
              Structured lessons, active-recall flashcards, challenge quizzes, and an optional
              on-device AI tutor—all in one native macOS app.
            </p>
            <div className="hero-actions">
              <a className="btn btn-primary btn-lg" href={downloadUrl}>
                Download free
              </a>
              <a
                className="btn btn-ghost btn-lg"
                href={`${repoUrl}/releases/tag/${RELEASE_TAG}`}
                target="_blank"
                rel="noopener noreferrer"
              >
                View release notes
              </a>
            </div>
            <div className="hero-meta">
              <span>Economics · Physics · History</span>
              <span>Local AI via Ollama · no cloud required</span>
              <span>Open source on GitHub</span>
            </div>
          </div>
        </div>
      </section>

      <section className="section wrap">
        <Reveal>
          <div className="section-head">
            <p className="section-kicker">See it in action</p>
            <h2>Everything you need, in one focused workspace</h2>
            <p>
              Dashboard, lessons, AI tutor—every screen is built for long study sessions with minimal distraction.
            </p>
          </div>
        </Reveal>
        <ProductShots />
      </section>

      <section className="section wrap">
        <Reveal>
          <div className="grid grid-3">
            <article className="card">
              <div className="card-icon" aria-hidden>
                📘
              </div>
              <h3>Structured lessons</h3>
              <p>
                Section-based content across Economics, Physics, and History with clear explanations
                and built-in glossary support.
              </p>
            </article>
            <article className="card">
              <div className="card-icon" aria-hidden>
                🃏
              </div>
              <h3>Active recall loops</h3>
              <p>
                Flashcards with mastery tracking and challenge quizzes that push you to retrieve
                knowledge under pressure.
              </p>
            </article>
            <article className="card">
              <div className="card-icon" aria-hidden>
                🤖
              </div>
              <h3>On-device AI tutor</h3>
              <p>
                Ask questions about your current lesson. Powered by Ollama and Gemma—runs entirely
                on your Mac, no cloud needed.
              </p>
            </article>
            <article className="card">
              <div className="card-icon" aria-hidden>
                📈
              </div>
              <h3>Progress tracking</h3>
              <p>
                XP, streaks, completion states, and achievements that keep you consistent without
                turning study into a game.
              </p>
            </article>
            <article className="card">
              <div className="card-icon" aria-hidden>
                🧩
              </div>
              <h3>Native macOS feel</h3>
              <p>
                SwiftUI-native with a clean sidebar, smooth transitions, and a design that holds up
                across hours of focused work.
              </p>
            </article>
            <article className="card">
              <div className="card-icon" aria-hidden>
                🌙
              </div>
              <h3>Multiple themes</h3>
              <p>
                Six built-in colour themes—Midnight, Ocean, Aurora, Ember, Lavender, and Slate—to
                match your preference or time of day.
              </p>
            </article>
          </div>
        </Reveal>
      </section>

      <section className="section wrap">
        <Reveal>
          <div className="cta-band">
            <div className="cta-mascot-wrap" aria-hidden>
              <Image className="cta-mascot" src="/mascot.png" alt="" width={120} height={75} />
            </div>
            <div className="cta-copy">
              <h2>Ready to actually study?</h2>
              <p>
                Download IBStudy free for {MACOS_REQUIREMENT}. Runs fully offline—no account, no subscription.
              </p>
              <div className="cta-actions">
                <a className="btn btn-primary" href={downloadUrl}>Download for Mac</a>
                <div className="cta-inline-links">
                  <Link href="/features">Features</Link>
                  <Link href="/subjects">Subjects</Link>
                  <Link href="/faq">FAQ</Link>
                </div>
              </div>
            </div>
          </div>
        </Reveal>
      </section>
    </>
  );
}
