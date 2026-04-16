import Image from "next/image";
import Link from "next/link";
import {
  APP_VERSION,
  MACOS_CODENAME,
  MACOS_REQUIREMENT,
  RELEASE_TAG,
  downloadUrl,
  repoUrl,
} from "@/lib/site";

export function SiteFooter() {
  return (
    <footer className="footer wrap">
      <div className="footer-grid">
        <div>
          <div className="footer-brand">
            <Image
              className="footer-mascot"
              src="/mascot.png"
              alt=""
              width={36}
              height={36}
            />
            IBStudy
          </div>
          <p style={{ maxWidth: 320 }}>
            A native macOS study workspace with focused lessons, active recall, challenge
            sessions, and optional local AI tutoring.
          </p>
          <p className="footer-meta">
            {MACOS_REQUIREMENT} ({MACOS_CODENAME}) · v{APP_VERSION}
          </p>
        </div>

        <div className="footer-col">
          <strong>Product</strong>
          <Link href="/features">Features</Link>
          <Link href="/subjects">Subjects</Link>
          <Link href="/ai-tutor">AI tutor</Link>
          <Link href="/download">Download</Link>
        </div>

        <div className="footer-col">
          <strong>Support</strong>
          <Link href="/faq">FAQ</Link>
          <Link href="/changelog">Changelog</Link>
          <a href={downloadUrl}>Latest DMG</a>
          <a href={`${repoUrl}/releases/tag/${RELEASE_TAG}`} target="_blank" rel="noopener noreferrer">
            Release notes
          </a>
        </div>
      </div>
      <p className="footer-disclaimer">
        IBStudy is an independent project and is not affiliated with or endorsed by the International
        Baccalaureate Organization. IB is a registered trademark of the International Baccalaureate
        Organization.
      </p>
    </footer>
  );
}
