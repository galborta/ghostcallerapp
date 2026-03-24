"use client";

import { motion, AnimatePresence } from "framer-motion";

interface AgentStatusProps {
  text: string;
}

export default function AgentStatus({ text }: AgentStatusProps) {
  if (!text) return null;

  return (
    <AnimatePresence mode="wait">
      <motion.p
        key={text}
        initial={{ opacity: 0, y: 5 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: -5 }}
        transition={{ duration: 0.2 }}
        className="text-sm text-zinc-400 font-medium text-center"
      >
        {text}
      </motion.p>
    </AnimatePresence>
  );
}
