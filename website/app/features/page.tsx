import type { Metadata } from "next";
import { PageIntro } from "../components/PageIntro";
import { ProductShots } from "../components/ProductShots";
import { Reveal } from "../components/Reveal";
import { absoluteUrl } from "@/lib/site";

export const metadata: Metadata = {
  title: "Features | IBStudy",
  description: "Explore IBStudy features across Learn, Review, Challenge, progress, and local AI tutoring.",
  alternates: { canonical: "/features" },
  openGraph: { url: absoluteUrl("/features") },
};

export default function FeaturesPage() {
  return (
    <>
      <PageIntro
        kicker="Features"
        title="Designed for focused, high-retention study sessions"
        lead="IBStudy combines structured content, active recall, challenge loops, and contextual AI support in one coherent workflow."
      />

      <section className="section wrap">
        <Reveal>
          <div className="grid grid-3">
            <article className="card">
              <div className="card-icon" aria-hidden>
                📘
              </div>
              <h3>Learn</h3>
              <p>Section-based lessons with clear explanations and glossary support for fast concept recovery.</p>
            </article>
            <article className="card">
              <div className="card-icon" aria-hidden>
                🃏
              </div>
              <h3>Review</h3>
              <p>Flashcard loops with mastery tracking to reinforce retrieval and reduce forgetting between sessions.</p>
            </article>
            <article className="card">
              <div className="card-icon" aria-hidden>
                🎯
              </div>
              <h3>Challenge</h3>
              <p>Challenge sets with explanations to sharpen exam-style reasoning and accuracy under pressure.</p>
            </article>
            <article className="card">
              <div className="card-icon" aria-hidden>
                📈
              </div>
              <h3>Progress design</h3>
              <p>XP, streaks, completion state, and achievements that encourage consistency without distractions.</p>
            </article>
            <article className="card">
              <div className="card-icon" aria-hidden>
                🤖
              </div>
              <h3>Local AI tutor</h3>
              <p>Optional on-device tutor via Ollama and Gemma models, with context from your current subject and lesson.</p>
            </article>
            <article className="card">
              <div className="card-icon" aria-hidden>
                🧩
              </div>
              <h3>Native macOS UX</h3>
              <p>SwiftUI-native interactions, clean hierarchy, and focused layouts that hold up in long sessions.</p>
            </article>
          </div>
        </Reveal>
      </section>

      <section className="section wrap">
        <Reveal>
          <div className="section-head">
            <p className="section-kicker">Visual walkthrough</p>
            <h2>How the product feels across workflows</h2>
            <p>From dashboard to challenge mode to AI support, every mode shares one cohesive interaction system.</p>
          </div>
        </Reveal>
        <ProductShots />
      </section>
    </>
  );
}
