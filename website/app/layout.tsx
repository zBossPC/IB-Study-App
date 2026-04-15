import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "IBStudy — macOS study app",
  description:
    "Native macOS app for IB/AP coursework: lessons, flashcards, quizzes, glossary, and a local AI tutor.",
  openGraph: {
    title: "IBStudy",
    description: "Download IBStudy for macOS",
    type: "website",
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
