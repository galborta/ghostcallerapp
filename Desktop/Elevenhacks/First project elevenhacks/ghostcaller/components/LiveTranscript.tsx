"use client";

import { useEffect, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { TranscriptEntry } from "@/lib/types";

interface LiveTranscriptProps {
  entries: TranscriptEntry[];
}

const roleStyles: Record<string, { label: string; color: string; bg: string }> = {
  user: {
    label: "You",
    color: "text-zinc-700",
    bg: "bg-zinc-100",
  },
  agent: {
    label: "Ghost Caller",
    color: "text-indigo-700",
    bg: "bg-indigo-50",
  },
  business: {
    label: "Business",
    color: "text-green-700",
    bg: "bg-green-50",
  },
};

export default function LiveTranscript({ entries }: LiveTranscriptProps) {
  const scrollRef = useRef<HTMLDivElement>(null);

  // Auto-scroll to bottom on new entries
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [entries]);

  if (entries.length === 0) return null;

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="w-full max-w-lg"
    >
      <div className="flex items-center gap-2 mb-2">
        <div className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
        <span className="text-xs font-medium text-zinc-400 uppercase tracking-wider">
          Live Transcript
        </span>
      </div>

      <div
        ref={scrollRef}
        className="transcript-scroll max-h-64 overflow-y-auto space-y-2 rounded-2xl border border-zinc-200 bg-white p-4"
      >
        <AnimatePresence mode="popLayout">
          {entries.map((entry) => {
            const style = roleStyles[entry.role] ?? roleStyles.agent;

            return (
              <motion.div
                key={entry.id}
                initial={{ opacity: 0, y: 10, scale: 0.98 }}
                animate={{ opacity: 1, y: 0, scale: 1 }}
                transition={{ duration: 0.2 }}
                className={`rounded-xl px-3 py-2 ${style.bg}`}
              >
                <div className="flex items-center gap-2 mb-0.5">
                  <span className={`text-xs font-semibold ${style.color}`}>
                    {style.label}
                  </span>
                  {entry.language && entry.language !== "en" && (
                    <span className="text-xs text-zinc-400">
                      🌐 {entry.language.toUpperCase()}
                    </span>
                  )}
                </div>
                <p className="text-sm text-zinc-700 leading-relaxed">
                  {entry.text}
                </p>
              </motion.div>
            );
          })}
        </AnimatePresence>
      </div>
    </motion.div>
  );
}
