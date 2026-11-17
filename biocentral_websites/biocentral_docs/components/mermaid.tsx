"use client";

import { useTheme } from "next-themes";
import { useEffect, useId, useRef } from "react";

type MermaidProps = {
  chart: string;
};

export function Mermaid({ chart }: MermaidProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const id = useId().replace(/:/g, "");
  const { resolvedTheme } = useTheme();

  useEffect(() => {
    let cancelled = false;

    const renderChart = async () => {
      const { default: mermaid } = await import("mermaid");
      if (cancelled || !containerRef.current) return;

      mermaid.initialize({
        startOnLoad: false,
        theme: resolvedTheme === "dark" ? "dark" : "default",
      });

      const { svg } = await mermaid.render(`mermaid-${id}`, chart);
      if (!cancelled && containerRef.current) {
        containerRef.current.innerHTML = svg;
      }
    };

    void renderChart().catch((error: unknown) => {
      if (!cancelled) console.error("Failed to render Mermaid diagram", error);
    });

    return () => {
      cancelled = true;
      containerRef.current?.replaceChildren();
    };
  }, [chart, id, resolvedTheme]);

  return <div ref={containerRef} className="my-4 overflow-x-auto" role="img" aria-label="Diagram" />;
}