import type { Metadata } from "next";
import { PageIntro } from "../components/PageIntro";
import { Reveal } from "../components/Reveal";
import { MACOS_CODENAME, MACOS_REQUIREMENT, RELEASE_TAG, absoluteUrl, downloadUrl, repoUrl } from "@/lib/site";

export const metadata: Metadata = {
  title: "Download | IBStudy",
  description: "Download IBStudy for macOS 26+ with step-by-step install and first-launch guidance.",
  alternates: { canonical: "/download" },
  openGraph: { url: absoluteUrl("/download") },
};

export default function DownloadPage() {
  return (
    <>
      <PageIntro
        kicker="Download"
        title={`Install IBStudy on ${MACOS_REQUIREMENT}`}
        lead={`Current target is ${MACOS_CODENAME}. Follow these steps for a clean DMG install and first launch.`}
      />

      <section className="section wrap">
        <Reveal>
          <div className="hero-actions">
            <a className="btn btn-primary btn-lg" href={downloadUrl}>
              Download IBStudy DMG
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
        </Reveal>
        <Reveal>
          <div className="steps">
            <div className="step">
              <div className="step-num">1</div>
              <div>
                <h3>Download and open the DMG</h3>
                <p>
                  Get <code>IBStudy-macos.dmg</code> from GitHub releases and open it in Finder.
                </p>
              </div>
            </div>
            <div className="step">
              <div className="step-num">2</div>
              <div>
                <h3>Move the app to Applications</h3>
                <p>Drag <strong>IBStudy.app</strong> into the Applications folder before launching.</p>
              </div>
            </div>
            <div className="step">
              <div className="step-num">3</div>
              <div>
                <h3>First launch and allow-open flow</h3>
                <p>If Gatekeeper blocks the app, use right-click → Open → Open once, then relaunch normally.</p>
              </div>
            </div>
          </div>
        </Reveal>
      </section>

      <section className="section wrap">
        <Reveal>
          <div className="callout">
            <h3>
              <span aria-hidden>⚠️</span> If macOS blocks startup
            </h3>
            <p>
              Open <strong>Finder</strong>, locate <strong>IBStudy.app</strong>, right-click and choose{" "}
              <strong>Open</strong>, then confirm. You can also allow the app in{" "}
              <strong>System Settings → Privacy &amp; Security</strong> after a blocked attempt.
            </p>
            <p className="callout-note">
              This distribution is currently unsigned for private/beta use. Notarization can be added for
              broader public distribution.
            </p>
          </div>
        </Reveal>
      </section>
    </>
  );
}
