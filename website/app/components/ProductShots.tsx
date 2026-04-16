import Image from "next/image";
import { Reveal } from "./Reveal";

const shots = [
  {
    src: "/shot-dashboard.svg",
    alt: "IBStudy dashboard view showing subject progress and learning path",
    title: "Mission dashboard",
    copy: "Track streaks, XP, and section completion in one focused view.",
  },
  {
    src: "/shot-learn.svg",
    alt: "IBStudy lesson workspace with sections, notes, and quiz panel",
    title: "Learn + challenge flow",
    copy: "Move from lessons to flashcards and challenge mode with minimal context switching.",
  },
  {
    src: "/shot-ai.svg",
    alt: "IBStudy AI tutor panel with contextual prompts and local model status",
    title: "Context-aware AI tutor",
    copy: "Ask targeted questions tied to your current lesson, with local model inference.",
  },
];

export function ProductShots() {
  return (
    <Reveal>
      <section className="proof-grid">
        {shots.map((shot) => (
          <article key={shot.src} className="proof-card">
            <Image src={shot.src} alt={shot.alt} width={1200} height={720} />
            <div className="proof-copy">
              <h3>{shot.title}</h3>
              <p>{shot.copy}</p>
            </div>
          </article>
        ))}
      </section>
    </Reveal>
  );
}
