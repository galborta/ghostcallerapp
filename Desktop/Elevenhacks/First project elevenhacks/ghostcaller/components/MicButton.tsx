"use client";

import { motion } from "framer-motion";
import { useCallback } from "react";

interface MicButtonProps {
  isConnected: boolean;
  isConnecting: boolean;
  isSpeaking: boolean; // user is holding the button
  onConnect: () => void;
  onPressStart: () => void;
  onPressEnd: () => void;
  onDisconnect: () => void;
  disabled?: boolean;
}

export default function MicButton({
  isConnected,
  isConnecting,
  isSpeaking,
  onConnect,
  onPressStart,
  onPressEnd,
  onDisconnect,
  disabled = false,
}: MicButtonProps) {
  // Visual states:
  // 1. Not connected: indigo mic icon — tap to connect
  // 2. Connecting: amber spinner
  // 3. Connected, not holding: indigo mic icon with "Hold to talk" hint
  // 4. Connected, holding: red mic icon with pulse — recording

  const getButtonStyle = () => {
    if (disabled) return "bg-zinc-100 text-zinc-300 cursor-not-allowed";
    if (isConnecting) return "bg-amber-500 text-white shadow-lg shadow-amber-200";
    if (isSpeaking) return "bg-red-500 text-white shadow-lg shadow-red-200";
    if (isConnected) return "bg-indigo-500 text-white shadow-lg shadow-indigo-200 hover:bg-indigo-600";
    return "bg-indigo-500 text-white shadow-lg shadow-indigo-200 hover:bg-indigo-600";
  };

  const handlePointerDown = useCallback(
    (e: React.PointerEvent | React.TouchEvent) => {
      e.preventDefault();
      if (disabled || isConnecting) return;
      if (!isConnected) {
        onConnect();
      } else {
        onPressStart();
      }
    },
    [disabled, isConnecting, isConnected, onConnect, onPressStart]
  );

  const handlePointerUp = useCallback(
    (e: React.PointerEvent | React.TouchEvent) => {
      e.preventDefault();
      if (isConnected && isSpeaking) {
        onPressEnd();
      }
    },
    [isConnected, isSpeaking, onPressEnd]
  );

  return (
    <div className="flex flex-col items-center gap-2">
      <div className="flex items-center gap-3">
        <motion.button
          whileTap={disabled || isConnecting ? {} : { scale: 0.95 }}
          onPointerDown={handlePointerDown}
          onPointerUp={handlePointerUp}
          onPointerLeave={handlePointerUp}
          onTouchStart={handlePointerDown}
          onTouchEnd={handlePointerUp}
          disabled={disabled}
          className={`
            relative flex items-center justify-center w-16 h-16 rounded-full
            transition-colors font-medium text-2xl select-none touch-none
            ${getButtonStyle()}
          `}
          aria-label={isSpeaking ? "Speaking..." : isConnected ? "Hold to talk" : "Start"}
        >
          {isConnecting ? (
            <motion.svg
              width="24" height="24" viewBox="0 0 24 24"
              fill="none" stroke="currentColor" strokeWidth="2"
              animate={{ rotate: 360 }}
              transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
            >
              <circle cx="12" cy="12" r="10" opacity="0.3" />
              <path d="M12 2a10 10 0 0 1 10 10" strokeDasharray="15.7 62.8" />
            </motion.svg>
          ) : (
            <svg
              width="24" height="24" viewBox="0 0 24 24"
              fill="none" stroke="currentColor" strokeWidth="2"
              strokeLinecap="round" strokeLinejoin="round"
            >
              <path d="M12 2a3 3 0 0 0-3 3v7a3 3 0 0 0 6 0V5a3 3 0 0 0-3-3Z" />
              <path d="M19 10v2a7 7 0 0 1-14 0v-2" />
              <line x1="12" x2="12" y1="19" y2="22" />
            </svg>
          )}

          {/* Recording pulse ring */}
          {isSpeaking && (
            <motion.div
              className="absolute inset-0 rounded-full border-2 border-red-400"
              animate={{ scale: [1, 1.5], opacity: [0.6, 0] }}
              transition={{ duration: 0.8, repeat: Infinity, ease: "easeOut" }}
            />
          )}

          {/* Connected idle pulse */}
          {isConnected && !isSpeaking && !isConnecting && (
            <motion.div
              className="absolute inset-0 rounded-full border-2 border-indigo-300"
              animate={{ scale: [1, 1.3], opacity: [0.3, 0] }}
              transition={{ duration: 2, repeat: Infinity, ease: "easeOut" }}
            />
          )}

          {/* Connecting pulse */}
          {isConnecting && (
            <motion.div
              className="absolute inset-0 rounded-full border-2 border-amber-300"
              animate={{ scale: [1, 1.4], opacity: [0.5, 0] }}
              transition={{ duration: 1.5, repeat: Infinity, ease: "easeOut" }}
            />
          )}
        </motion.button>

        {/* End session button */}
        {isConnected && !isSpeaking && (
          <motion.button
            initial={{ opacity: 0, scale: 0.8, x: -10 }}
            animate={{ opacity: 1, scale: 1, x: 0 }}
            exit={{ opacity: 0, scale: 0.8, x: -10 }}
            onClick={onDisconnect}
            className="flex items-center justify-center w-10 h-10 rounded-full bg-zinc-200 text-zinc-500 hover:bg-red-100 hover:text-red-500 transition-colors"
            aria-label="End session"
          >
            <svg width="14" height="14" viewBox="0 0 14 14" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
              <path d="M1 1l12 12M13 1L1 13" />
            </svg>
          </motion.button>
        )}
      </div>

      {/* Hint text */}
      <span className="text-xs text-zinc-400 select-none">
        {isConnecting
          ? "Connecting..."
          : isSpeaking
            ? "Release to send"
            : isConnected
              ? "Hold to talk"
              : "Tap to start"}
      </span>
    </div>
  );
}
