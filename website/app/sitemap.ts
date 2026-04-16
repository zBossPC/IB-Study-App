import type { MetadataRoute } from "next";
import { absoluteUrl } from "@/lib/site";

const routes = ["", "/features", "/subjects", "/ai-tutor", "/download", "/faq", "/changelog"];

export default function sitemap(): MetadataRoute.Sitemap {
  const now = new Date();
  return routes.map((route) => ({
    url: absoluteUrl(route || "/"),
    lastModified: now,
    changeFrequency: route ? "weekly" : "daily",
    priority: route ? 0.75 : 1,
  }));
}
