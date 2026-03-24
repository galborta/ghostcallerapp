"use client";

import { motion, AnimatePresence } from "framer-motion";
import { CallStatus as CallStatusType } from "@/lib/types";

interface CallStatusProps {
  status: CallStatusType;
  businessName?: string;
  duration?: number;
}

const statusConfig: Record<
  CallStatusType,
  { label: string; icon: string; color: string; animate: boolean }
> = {
  idle: { label: "", icon: "", color: "", animate: false },
  searching: {
    label: "Searching the web...",
    icon: "🔍",
    color: "text-amber-600",
    animate: true,
  },
  found: {
    label: "Found results!",
    icon: "✅",
    color: "text-green-600",
    animate: false,
  },
  dialing: {
    label: "Dialing...",
    icon: "📞",
    color: "text-indigo-600",
    animate: true,
  },
  ringing: {
    label: "Ringing...",
    icon: "🔔",
    color: "text-indigo-600",
    animate: true,
  },
  connected: {
    label: "Connected — on the call",
    icon: "🟢",
    color: "text-green-600",
    animate: true,
  },
  completed: {
    label: "Call completed",
    icon: "✅",
    color: "text-green-600",
    animate: false,
  },
  failed: {
    label: "Call failed",
    icon: "❌",
    color: "text-red-500",
    animate: false,
  },
  "no-answer": {
    label: "No answer",
    icon: "📵",
    color: "text-zinc-500",
    animate: false,
  },
};

export default function CallStatus({
  status,
  businessName,
  duration,
}: CallStatusProps) {
  if (status === "idle") return null;

  const config = statusConfig[status];

  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={status}
        initial={{ opacity: 0, y: -10 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: 10 }}
        className="flex items-center gap-3 px-4 py-2.5 rounded-full bg-white border border-zinc-200 shadow-sm"
      >
        {config.animate ? (
          <motion.span
            animate={{ scale: [1, 1.2, 1] }}
            transition={{ duration: 1, repeat: Infinity }}
            className="text-lg"
          >
            {config.icon}
          </motion.span>
        ) : (
          <span className="text-lg">{config.icon}</span>
        )}

        <div className="flex flex-col">
          <span className={`text-sm font-medium ${config.color}`}>
            {config.label}
          </span>
          {businessName && (
            <span className="text-xs text-zinc-400">{businessName}</span>
          )}
          {duration !== undefined && status === "completed" && (
            <span className="text-xs text-zinc-400">
              Duration: {Math.floor(duration / 60)}:{String(duration % 60).padStart(2, "0")}
            </span>
          )}
        </div>
      </motion.div>
    </AnimatePresence>
  );
}
