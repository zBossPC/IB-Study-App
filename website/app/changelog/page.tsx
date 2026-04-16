import type { Metadata } from "next";
import { PageIntro } from "../components/PageIntro";
import { Reveal } from "../components/Reveal";
import { absoluteUrl } from "@/lib/site";

export const metadata: Metadata = {
  title: "Changelog | IBStudy",
  description: "Recent IBStudy release highlights and product updates.",
  alternates: { canonical: "/changelog" },
  openGraph: { url: absoluteUrl("/changelog") },
};

const releases = [
  {
    version: "1.0.13",
    date: "2026-04-15",
    notes: [
      "Shipped a full multi-page website overhaul (Home, Features, Subjects, AI Tutor, Download, FAQ, Changelog).",
      "Added mobile navigation, accessibility focus states, skip-link, sitemap/robots, and centralized macOS 26+ messaging.",
    ],
  },
  {
    version: "1.0.12",
    date: "2026-04-15",
    notes: [
      "Website navigation and spacing overhaul with improved tab sizing and readability.",
      "Published new signed appcast entry and updated DMG distribution pipeline.",
    ],
  },
  {
    version: "1.0.11",
    date: "2026-04-15",
    notes: [
      "Added new content packs: Economics Unit 4, Physics Magnetism, and History of the Americas.",
      "Updated theme/icon mappings and release packaging for additional resources.",
    ],
  },
  {
    version: "1.0.10",
    date: "2026-04-15",
    notes: [
      "Polished mascot visibility and sizing across major app surfaces.",
      "Refined sidebar subject presentation with improved layout consistency.",
    ],
  },
];

export default function ChangelogPage() {
  return (
    <>
      <PageIntro
        kicker="Changelog"
        title="Recent releases"
        lead="A concise view of what changed in the latest IBStudy versions."
      />

      <section className="section wrap">
        <Reveal>
          <div className="timeline">
            {releases.map((release) => (
              <article key={release.version} className="timeline-item">
                <p className="timeline-meta">
                  v{release.version} · <time>{release.date}</time>
                </p>
                <ul>
                  {release.notes.map((note) => (
                    <li key={note}>{note}</li>
                  ))}
                </ul>
              </article>
            ))}
          </div>
        </Reveal>
      </section>
    </>
  );
}
