const defaultDownload =
  process.env.NEXT_PUBLIC_DOWNLOAD_URL?.trim() || "";
const defaultRepo = process.env.NEXT_PUBLIC_GITHUB_REPO_URL?.trim() || "";

export default function Home() {
  const hasDownload = defaultDownload.length > 0;

  return (
    <main
      style={{
        minHeight: "100vh",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        padding: "48px 24px 80px",
      }}
    >
      <div
        style={{
          maxWidth: 720,
          width: "100%",
          textAlign: "center",
        }}
      >
        <p
          style={{
            fontSize: "0.75rem",
            letterSpacing: "0.2em",
            textTransform: "uppercase",
            color: "var(--muted)",
            marginBottom: 12,
          }}
        >
          Friends &amp; beta
        </p>
        <h1
          style={{
            fontSize: "clamp(2rem, 5vw, 2.75rem)",
            fontWeight: 800,
            letterSpacing: "-0.03em",
            margin: "0 0 16px",
            lineHeight: 1.15,
          }}
        >
          IBStudy
        </h1>
        <p
          style={{
            fontSize: "1.125rem",
            color: "var(--muted)",
            lineHeight: 1.6,
            margin: "0 auto 40px",
            maxWidth: 520,
          }}
        >
          A native macOS study app for IB/AP coursework: interactive lessons,
          diagrams, flashcards, quizzes, a glossary, and a local AI tutor
          (Ollama).
        </p>

        <div
          style={{
            background: "var(--panel)",
            border: "1px solid var(--stroke)",
            borderRadius: "var(--radius)",
            padding: "28px 24px 32px",
            backdropFilter: "blur(12px)",
            marginBottom: 28,
          }}
        >
          <p style={{ margin: "0 0 20px", fontSize: "0.9rem", color: "var(--muted)" }}>
            Requires <strong style={{ color: "var(--text)" }}>macOS 14+</strong> (Apple Silicon
            or Intel). For friends: download the zip from GitHub Releases, unzip, and drag{" "}
            <code style={{ fontSize: "0.85em", opacity: 0.9 }}>IBStudy.app</code> into{" "}
            <code style={{ fontSize: "0.85em", opacity: 0.9 }}>Applications</code>.
          </p>

          {hasDownload ? (
            <a
              href={defaultDownload}
              style={{
                display: "inline-flex",
                alignItems: "center",
                justifyContent: "center",
                gap: 10,
                padding: "14px 28px",
                fontSize: "1rem",
                fontWeight: 700,
                color: "#0a0e14",
                background: "linear-gradient(135deg, #7ec8f0 0%, #5b9fd4 50%, #4a8fc4 100%)",
                borderRadius: 14,
                boxShadow: "0 8px 32px rgba(91, 159, 212, 0.35)",
              }}
            >
              Download for macOS
            </a>
          ) : (
            <p style={{ margin: 0, fontSize: "0.95rem", color: "var(--muted)" }}>
              Set{" "}
              <code style={{ fontSize: "0.85em" }}>NEXT_PUBLIC_DOWNLOAD_URL</code> in Vercel
              (see <code style={{ fontSize: "0.85em" }}>website/README.md</code>) to point at
              your latest Release asset.
            </p>
          )}

          {defaultRepo && (
            <p style={{ margin: "20px 0 0", fontSize: "0.875rem" }}>
              <a href={defaultRepo}>Source on GitHub</a>
            </p>
          )}
        </div>

        <section
          style={{
            textAlign: "left",
            background: "rgba(0,0,0,0.2)",
            border: "1px solid var(--stroke)",
            borderRadius: "var(--radius)",
            padding: "22px 22px 24px",
          }}
        >
          <h2 style={{ fontSize: "1rem", fontWeight: 700, margin: "0 0 12px" }}>
            First open (unsigned build)
          </h2>
          <p style={{ margin: "0 0 10px", fontSize: "0.9rem", color: "var(--muted)", lineHeight: 1.55 }}>
            If macOS says the app can’t be opened because it’s from an unidentified developer:
            right-click <strong>IBStudy.app</strong> → <strong>Open</strong> → <strong>Open</strong>{" "}
            again. Or: System Settings → Privacy &amp; Security → allow the app when prompted.
          </p>
          <p style={{ margin: 0, fontSize: "0.85rem", color: "var(--muted)", opacity: 0.85 }}>
            For a wider public release, Apple’s Developer Program (~$99/year) lets you sign and
            notarize so Gatekeeper is quieter — optional for friends-only sharing.
          </p>
        </section>

        <footer style={{ marginTop: 40, fontSize: "0.8rem", color: "var(--muted)" }}>
          IBStudy · not affiliated with the IB Organization
        </footer>
      </div>
    </main>
  );
}
