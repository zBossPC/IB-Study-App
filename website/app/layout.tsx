import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "IBStudy — AP & IB study app for Mac",
  description:
    "Native macOS app for rigorous coursework: interactive lessons, diagrams, flashcards, quizzes, glossary, and optional local AI. Download the DMG for macOS 14+.",
  openGraph: {
    title: "IBStudy — Study smarter on your Mac",
    description:
      "Lessons, diagrams, flashcards, quizzes, and an optional local AI tutor. Free download for friends & beta.",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "IBStudy for macOS",
    description: "Interactive study app for AP / IB-style coursework.",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
