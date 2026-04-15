import type { Metadata } from "next";
import { DM_Sans } from "next/font/google";
import "./globals.css";

const dmSans = DM_Sans({
  subsets: ["latin"],
  display: "swap",
  variable: "--font-sans",
});

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
    <html lang="en" className={dmSans.variable}>
      <body className={dmSans.className}>{children}</body>
    </html>
  );
}
