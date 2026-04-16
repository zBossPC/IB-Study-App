import Image from "next/image";
import Link from "next/link";
import { downloadUrl, primaryNav, repoUrl } from "@/lib/site";

export function SiteHeader() {
  return (
    <header className="nav">
      <div className="nav-inner">
        <Link href="/" className="nav-brand">
          <span className="nav-brand-mark" aria-hidden>
            <Image
              className="nav-mascot-img"
              src="/mascot.png"
              alt=""
              width={28}
              height={28}
              priority
            />
          </span>
          IBStudy
        </Link>

        <nav className="nav-links" aria-label="Primary">
          {primaryNav.map((item) => (
            <Link key={item.href} href={item.href}>
              {item.label}
            </Link>
          ))}
        </nav>

        <div className="nav-cta">
          <a
            className="btn btn-ghost"
            href={repoUrl}
            target="_blank"
            rel="noopener noreferrer"
          >
            View source
          </a>
          <a className="btn btn-primary" href={downloadUrl}>
            Download
          </a>
        </div>

        <details className="mobile-nav">
          <summary aria-label="Open menu">
            <span />
            <span />
            <span />
          </summary>
          <div className="mobile-nav-panel">
            {primaryNav.map((item) => (
              <Link key={item.href} href={item.href}>
                {item.label}
              </Link>
            ))}
            <a
              href={repoUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="mobile-source"
            >
              View source on GitHub
            </a>
          </div>
        </details>
      </div>
    </header>
  );
}
