import Image from "next/image";
import Link from "next/link";
import { downloadUrl, primaryNav, repoUrl } from "@/lib/site";

export function SiteHeader() {
  return (
    <header className="nav">
      <div className="nav-inner">
        <div className="nav-left">
          <Link href="/" className="nav-brand">
            <span className="nav-brand-mark" aria-hidden>
              <Image
                className="nav-mascot-img"
                src="/icon.png"
                alt=""
                width={36}
                height={36}
                priority
              />
            </span>
            IBStudy
          </Link>
        </div>

        <div className="nav-center">
          <nav className="nav-links" aria-label="Primary">
            {primaryNav.map((item) => (
              <Link key={item.href} href={item.href}>
                {item.label}
              </Link>
            ))}
          </nav>
        </div>

        <div className="nav-right">
          <div className="nav-cta">
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
      </div>
    </header>
  );
}
