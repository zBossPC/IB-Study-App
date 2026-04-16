import type { Metadata } from "next";
import { PageIntro } from "../components/PageIntro";
import { Reveal } from "../components/Reveal";
import { absoluteUrl } from "@/lib/site";

export const metadata: Metadata = {
  title: "Subjects | IBStudy",
  description: "Browse IBStudy subject coverage across Economics, Physics, and History of the Americas.",
  alternates: { canonical: "/subjects" },
  openGraph: { url: absoluteUrl("/subjects") },
};

export default function SubjectsPage() {
  return (
    <>
      <PageIntro
        kicker="Subjects"
        title="Expanding AP/IB-style subject coverage"
        lead="IBStudy now includes multiple Economics and Physics units plus a dedicated History of the Americas track."
      />

      <section className="section wrap">
        <Reveal>
          <div className="grid grid-3">
            <article className="card">
              <div className="card-icon" aria-hidden>
                📊
              </div>
              <h3>Economics</h3>
              <p>
                Unit 3 and Unit 4 content with structured lessons, flashcards, and challenge sets on market
                structures, monopoly behavior, and strategic decision-making.
              </p>
            </article>
            <article className="card">
              <div className="card-icon" aria-hidden>
                🧲
              </div>
              <h3>Physics</h3>
              <p>
                Static Electricity and Magnetism units covering conceptual foundations, formulas, applied
                problem-solving, and exam-style checks.
              </p>
            </article>
            <article className="card">
              <div className="card-icon" aria-hidden>
                🏛️
              </div>
              <h3>History of the Americas</h3>
              <p>
                Cold War and Social Movements (1945–2001) with thematic sections, key developments, and
                retrieval-oriented review items.
              </p>
            </article>
          </div>
        </Reveal>
      </section>

      <section className="section wrap">
        <Reveal>
          <div className="section-head">
            <p className="section-kicker">Learning design</p>
            <h2>Same loop, every subject</h2>
            <p>Each subject follows the same Learn → Review → Challenge flow so students can stay in rhythm.</p>
          </div>
        </Reveal>
        <Reveal>
          <div className="steps">
            <div className="step">
              <div className="step-num">1</div>
              <div>
                <h3>Build core understanding</h3>
                <p>Read section lessons and use the glossary to close vocabulary gaps immediately.</p>
              </div>
            </div>
            <div className="step">
              <div className="step-num">2</div>
              <div>
                <h3>Stress-test recall</h3>
                <p>Run flashcards to pressure memory before switching to challenge mode.</p>
              </div>
            </div>
            <div className="step">
              <div className="step-num">3</div>
              <div>
                <h3>Convert to exam confidence</h3>
                <p>Use challenge feedback and AI tutor explanations to lock in test-day reasoning speed.</p>
              </div>
            </div>
          </div>
        </Reveal>
      </section>
    </>
  );
}
