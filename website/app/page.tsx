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
          <span className="hero-badge">v{APP_VERSION}</span>
          <span className="hero-badge-sub">A calmer, higher-quality way to study on Mac</span>
        </div>

        <div className="hero-split">
          <div className="hero-mascot">
            <Image
              className="hero-mascot-img"
              src="/mascot.png"
              alt="IBStudy mascot in the app and AI tutor"
              width={320}
              height={200}
              priority
            />
          </div>
          <div className="hero-copy">
            <p className="hero-kicker">
              IBStudy brings rigorous coursework, active-recall loops, and optional local AI coaching
              into one focused native workspace.
            </p>
            <h1>
              <span className="hero-gradient">A full study stack</span>
              <br />
              built for your Mac.
            </h1>
            <p className="hero-lead">
              Move from lessons to review to challenge mode across Economics, Physics, and History of
              the Americas—with contextual tutor support that stays on-device.
            </p>
            <div className="hero-actions">
              <a className="btn btn-primary btn-lg" href={downloadUrl}>
                Download for {MACOS_REQUIREMENT}
              </a>
              <a
                className="btn btn-ghost btn-lg"
                href={`${repoUrl}/releases/tag/${RELEASE_TAG}`}
                target="_blank"
                rel="noopener noreferrer"
              >
                Release notes
              </a>
            </div>
            <div className="hero-meta">
              <span>
                <strong style={{ color: "var(--text-muted)" }}>{MACOS_REQUIREMENT}</strong>&nbsp;(
                {MACOS_CODENAME}) · Apple Silicon & Intel
              </span>
              <span>Unsigned DMG · private/beta sharing</span>
              <span>Optional local AI via Ollama</span>
            </div>
          </div>
        </div>
      </section>

      <section className="section wrap">
        <Reveal>
          <div className="section-head">
            <p className="section-kicker">Product quality</p>
            <h2>Real product views, not just promises</h2>
            <p>
              The app is designed to feel cohesive across dashboard, learning flow, and tutoring. This
              site now reflects that same quality bar.
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
                ✨
              </div>
              <h3>Quality-focused UX</h3>
              <p>
                Cleaner hierarchy, better spacing, and purpose-built pages for each stage of the user
                journey.
              </p>
            </article>
            <article className="card">
              <div className="card-icon" aria-hidden>
                🧭
              </div>
              <h3>Clear navigation</h3>
              <p>
                Full desktop and mobile navigation across Features, Subjects, AI Tutor, Download, FAQ,
                and Changelog.
              </p>
            </article>
            <article className="card">
              <div className="card-icon" aria-hidden>
                🛡️
              </div>
              <h3>Trust + onboarding</h3>
              <p>
                Better install guidance, first-run troubleshooting, and transparent local AI and
                unsigned DMG messaging.
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
              <h2>Explore the full product site</h2>
              <p>
                Dive into feature breakdowns, subject coverage, setup docs, FAQ, and release history.
              </p>
              <div className="cta-inline-links">
                <Link href="/features">Features</Link>
                <Link href="/subjects">Subjects</Link>
                <Link href="/download">Download</Link>
                <Link href="/faq">FAQ</Link>
              </div>
            </div>
          </div>
        </Reveal>
      </section>
    </>
  );
}
