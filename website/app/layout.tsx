import type { Metadata } from "next";
import { DM_Sans } from "next/font/google";
import { SiteBackground } from "./components/SiteBackground";
import { SiteFooter } from "./components/SiteFooter";
import { SiteHeader } from "./components/SiteHeader";
import {
  APP_VERSION,
  MACOS_CODENAME,
  MACOS_REQUIREMENT,
  absoluteUrl,
  downloadUrl,
  repoUrl,
  siteUrl,
} from "@/lib/site";
import "./globals.css";

const dmSans = DM_Sans({
  subsets: ["latin"],
  display: "swap",
  variable: "--font-sans",
});

export const metadata: Metadata = {
  title: "IBStudy — AP & IB study app for Mac",
  description:
    `Native ${MACOS_REQUIREMENT} (${MACOS_CODENAME}) app for rigorous coursework: interactive lessons, diagrams, flashcards, quizzes, glossary, and optional local AI tutor.`,
  metadataBase: new URL(siteUrl),
  alternates: { canonical: "/" },
  openGraph: {
    title: "IBStudy — Study smarter on your Mac",
    description:
      `Focused study workspace for ${MACOS_REQUIREMENT}: lessons, drills, glossary, and optional on-device AI tutor.`,
    type: "website",
    url: absoluteUrl("/"),
    images: [
      {
        url: absoluteUrl("/shot-dashboard.svg"),
        width: 1200,
        height: 720,
        alt: "IBStudy dashboard preview",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "IBStudy for macOS",
    description: `Interactive study app for AP / IB-style coursework on ${MACOS_REQUIREMENT}.`,
    images: [absoluteUrl("/shot-dashboard.svg")],
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const appJsonLd = {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    name: "IBStudy",
    operatingSystem: `${MACOS_REQUIREMENT} (${MACOS_CODENAME})`,
    applicationCategory: "EducationalApplication",
    softwareVersion: APP_VERSION,
    downloadUrl,
    url: siteUrl,
    publisher: {
      "@type": "Organization",
      name: "IBStudy",
      url: repoUrl,
    },
  };

  return (
    <html lang="en" className={dmSans.variable}>
      <body className={dmSans.className}>
        <a href="#main-content" className="skip-link">
          Skip to main content
        </a>
        <SiteBackground />
        <SiteHeader />
        <main id="main-content">{children}</main>
        <SiteFooter />
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(appJsonLd) }}
        />
        <noscript>
          <style>{`.reveal{opacity:1 !important; transform:none !important;}`}</style>
        </noscript>
      </body>
    </html>
  );
}
