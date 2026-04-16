import type { Metadata } from "next";
import Image from "next/image";
import { PageIntro } from "../components/PageIntro";
import { Reveal } from "../components/Reveal";
import { absoluteUrl } from "@/lib/site";

export const metadata: Metadata = {
  title: "AI Tutor | IBStudy",
  description: "Learn how IBStudy's optional local AI tutor works with Ollama and context-aware prompts.",
  alternates: { canonical: "/ai-tutor" },
  openGraph: { url: absoluteUrl("/ai-tutor") },
};

export default function AITutorPage() {
  return (
    <>
      <PageIntro
        kicker="AI Tutor"
        title="A study coach that feels native to the app"
        lead="IBStudy's AI tutor is optional, local-first, and context-aware. It understands what subject and section you're currently studying."
      />

      <section className="section wrap ai-section">
        <Reveal>
          <div className="ai-showcase">
            <div className="ai-showcase-visual">
              <Image
                className="ai-showcase-mascot"
                src="/mascot.png"
                alt="IBStudy mascot used in the local AI tutor"
                width={280}
                height={175}
              />
            </div>
            <ul className="ai-points">
              <li>
                <strong>Context-aware prompts</strong> — the tutor uses your current subject/section context
                for cleaner explanations.
              </li>
              <li>
                <strong>Local inference</strong> — Ollama-backed model execution keeps tutoring data on your
                machine.
              </li>
              <li>
                <strong>Gemma defaults</strong> — tuned for practical performance and responsiveness on modern Macs.
              </li>
              <li>
                <strong>Two entry points</strong> — full window for deep sessions, menu bar for quick checks.
              </li>
            </ul>
          </div>
        </Reveal>
      </section>

      <section className="section wrap">
        <Reveal>
          <div className="grid grid-3">
            <article className="card">
              <div className="card-icon" aria-hidden>
                🔒
              </div>
              <h3>Privacy-first by default</h3>
              <p>No cloud API requirement for core tutoring workflows after local setup completes.</p>
            </article>
            <article className="card">
              <div className="card-icon" aria-hidden>
                🧠
              </div>
              <h3>Better explanations</h3>
              <p>Use the tutor to request step-by-step reasoning, concept comparisons, and targeted drills.</p>
            </article>
            <article className="card">
              <div className="card-icon" aria-hidden>
                ⚙️
              </div>
              <h3>Optional feature</h3>
              <p>The app remains fully usable without AI; lessons, flashcards, and quizzes are always available.</p>
            </article>
          </div>
        </Reveal>
      </section>
    </>
  );
}
