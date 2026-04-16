import type { Metadata } from "next";
import { PageIntro } from "../components/PageIntro";
import { Reveal } from "../components/Reveal";
import { MACOS_REQUIREMENT, absoluteUrl } from "@/lib/site";

export const metadata: Metadata = {
  title: "FAQ | IBStudy",
  description: "Frequently asked questions for IBStudy installation, compatibility, and local AI setup.",
  alternates: { canonical: "/faq" },
  openGraph: { url: absoluteUrl("/faq") },
};

const faqItems = [
  {
    q: "What macOS versions are supported?",
    a: `IBStudy currently targets ${MACOS_REQUIREMENT}.`,
  },
  {
    q: "Why does macOS say the app can't be opened?",
    a: "The DMG is currently distributed unsigned for private/beta testing. Use the right-click → Open flow once to allow launch.",
  },
  {
    q: "Does the app require the AI tutor?",
    a: "No. Lessons, flashcards, quizzes, and glossary all work without enabling AI.",
  },
  {
    q: "Where does AI inference run?",
    a: "On your machine via Ollama when enabled. Core tutoring prompts are designed for local execution.",
  },
  {
    q: "Can I use IBStudy offline?",
    a: "Yes for core study content. AI-specific workflows depend on your local model/runtime setup.",
  },
  {
    q: "How do I report issues or request features?",
    a: "Open an issue in the GitHub repository and include app version, macOS version, and clear reproduction steps.",
  },
];

export default function FAQPage() {
  return (
    <>
      <PageIntro
        kicker="FAQ"
        title="Answers for install, setup, and compatibility"
        lead="These are the most common questions from early users and private-beta testers."
      />

      <section className="section wrap">
        <Reveal>
          <div className="faq-list">
            {faqItems.map((item) => (
              <details key={item.q} className="faq-item">
                <summary>{item.q}</summary>
                <p>{item.a}</p>
              </details>
            ))}
          </div>
        </Reveal>
      </section>
    </>
  );
}
