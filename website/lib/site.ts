export const SITE_NAME = "IBStudy";
export const APP_VERSION = "1.0.14";
export const RELEASE_TAG = `v${APP_VERSION}`;
export const MACOS_REQUIREMENT = "macOS 26+";
export const MACOS_CODENAME = "Tahoe";

const DEFAULT_REPO = "https://github.com/zBossPC/IB-Study-App";
const DEFAULT_SITE_URL = "https://ibstudy.vercel.app";
const DEFAULT_DOWNLOAD = `${DEFAULT_REPO}/releases/download/${RELEASE_TAG}/IBStudy-macos.dmg`;

export const repoUrl =
  process.env.NEXT_PUBLIC_GITHUB_REPO_URL?.trim() || DEFAULT_REPO;
export const siteUrl =
  process.env.NEXT_PUBLIC_SITE_URL?.trim() || DEFAULT_SITE_URL;
export const downloadUrl =
  process.env.NEXT_PUBLIC_DOWNLOAD_URL?.trim() || DEFAULT_DOWNLOAD;

export const primaryNav = [
  { href: "/", label: "Home" },
  { href: "/features", label: "Features" },
  { href: "/subjects", label: "Subjects" },
  { href: "/ai-tutor", label: "AI Tutor" },
  { href: "/download", label: "Download" },
  { href: "/faq", label: "FAQ" },
  { href: "/changelog", label: "Changelog" },
] as const;

export function absoluteUrl(path: string) {
  return `${siteUrl.replace(/\/$/, "")}${path}`;
}
