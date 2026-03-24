"use client";

import { motion } from "framer-motion";
import { AgentPhase } from "@/lib/types";

interface AudioOrbProps {
  phase: AgentPhase;
}

const phaseColors: Record<AgentPhase, string[]> = {
  idle: ["#e4e4e7", "#d4d4d8"],
  listening: ["#6366f1", "#818cf8"],
  thinking: ["#818cf8", "#a78bfa"],
  searching: ["#f59e0b", "#fbbf24"],
  speaking: ["#6366f1", "#4f46e5"],
  calling: ["#22c55e", "#16a34a"],
  "on-call": ["#22c55e", "#15803d"],
};

const phaseScale: Record<AgentPhase, number> = {
  idle: 1,
  listening: 1.05,
  thinking: 1.1,
  searching: 1.08,
  speaking: 1.15,
  calling: 1.1,
  "on-call": 1.12,
};

export default function AudioOrb({ phase }: AudioOrbProps) {
  const colors = phaseColors[phase];
  const baseScale = phaseScale[phase];

  return (
    <div className="relative flex items-center justify-center w-48 h-48">
      {/* Outer glow ring */}
      <motion.div
        className="absolute rounded-full"
        animate={{
          scale: [baseScale * 1.3, baseScale * 1.5, baseScale * 1.3],
          opacity: [0.1, 0.2, 0.1],
        }}
        transition={{
          duration: 3,
          repeat: Infinity,
          ease: "easeInOut",
        }}
        style={{
          width: "100%",
          height: "100%",
          background: `radial-gradient(circle, ${colors[0]}40, transparent 70%)`,
        }}
      />

      {/* Middle pulse ring */}
      <motion.div
        className="absolute rounded-full"
        animate={{
          scale: [baseScale * 1.1, baseScale * 1.25, baseScale * 1.1],
          opacity: [0.15, 0.3, 0.15],
        }}
        transition={{
          duration: 2,
          repeat: Infinity,
          ease: "easeInOut",
          delay: 0.5,
        }}
        style={{
          width: "75%",
          height: "75%",
          background: `radial-gradient(circle, ${colors[0]}60, transparent 70%)`,
        }}
      />

      {/* Main orb - phase-based scale only, no audioLevel jitter */}
      <motion.div
        className="relative rounded-full shadow-2xl"
        animate={{
          scale: baseScale,
        }}
        transition={{
          type: "spring",
          stiffness: 300,
          damping: 20,
        }}
        style={{
          width: "50%",
          height: "50%",
          background: `radial-gradient(circle at 35% 35%, ${colors[1]}, ${colors[0]})`,
          boxShadow: `0 0 40px ${colors[0]}50, 0 0 80px ${colors[0]}20`,
        }}
      />

      {/* Center highlight */}
      <motion.div
        className="absolute rounded-full"
        animate={{
          opacity: [0.6, 0.9, 0.6],
        }}
        transition={{
          duration: 2,
          repeat: Infinity,
          ease: "easeInOut",
        }}
        style={{
          width: "15%",
          height: "15%",
          background: "radial-gradient(circle, rgba(255,255,255,0.8), transparent)",
          top: "35%",
          left: "38%",
        }}
      />
    </div>
  );
}
