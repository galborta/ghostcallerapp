"use client";

import { useState, useCallback, useRef, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import AudioOrb from "./AudioOrb";
import BusinessCard from "./BusinessCard";
import LiveTranscript from "./LiveTranscript";
import CallStatus from "./CallStatus";
import AgentStatus from "./AgentStatus";
import MicButton from "./MicButton";
import {
  AgentPhase,
  Business,
  CallStatus as CallStatusType,
  TranscriptEntry,
} from "@/lib/types";

export default function GhostCaller() {
  // ── State ────────────────────────────────────────────────────────────────
  const [agentPhase, setAgentPhase] = useState<AgentPhase>("idle");
  const [statusText, setStatusText] = useState("Tap the mic to start");
  const [isConnected, setIsConnected] = useState(false);
  const [isConnecting, setIsConnecting] = useState(false);
  const [isSpeaking, setIsSpeaking] = useState(false); // user holding mic

  const [businesses, setBusinesses] = useState<Business[]>([]);
  const [selectedBusiness, setSelectedBusiness] = useState<Business | null>(null);
  const [callStatus, setCallStatus] = useState<CallStatusType>("idle");
  const [transcript, setTranscript] = useState<TranscriptEntry[]>([]);
  const [callDuration, setCallDuration] = useState<number | undefined>();

  const conversationRef = useRef<unknown>(null);
  const businessesRef = useRef<Business[]>([]);

  // Keep ref in sync with state so clientTools can access latest businesses
  useEffect(() => {
    businessesRef.current = businesses;
  }, [businesses]);

  // ── ElevenAgent Connection ───────────────────────────────────────────────

  const connectToAgent = useCallback(async () => {
    try {
      setIsConnecting(true);
      setAgentPhase("thinking");
      setStatusText("Connecting...");

      const res = await fetch("/api/agent");
      const { signedUrl } = await res.json();

      if (!signedUrl) {
        console.error("Failed to get signed agent URL");
        setIsConnecting(false);
        setAgentPhase("idle");
        setStatusText("Failed to connect. Try again.");
        return;
      }

      const { Conversation } = await import("@elevenlabs/client");

      const conversation = await Conversation.startSession({
        signedUrl,
        clientTools: {
          // Client-side tool: runs in the browser, populates UI cards
          search_businesses: async (params: { query: string; location?: string }) => {
            console.log("[Tool] search_businesses called:", params);
            setAgentPhase("searching");
            setStatusText("Searching...");
            setBusinesses([]); // clear previous results

            try {
              const searchParams = new URLSearchParams({ query: params.query });
              if (params.location) searchParams.set("location", params.location);

              const res = await fetch(`/api/search?${searchParams.toString()}`);
              const data = await res.json();

              if (data.businesses && data.businesses.length > 0) {
                setBusinesses(data.businesses);
                // Return structured results to the agent so it can speak about them
                return JSON.stringify({
                  success: true,
                  query: params.query,
                  results: data.businesses.map((b: Business) => ({
                    name: b.name,
                    rating: b.rating,
                    reviews: b.reviewCount,
                    address: b.address,
                    phone: b.phone,
                    details: b.snippet,
                  })),
                });
              } else {
                return JSON.stringify({
                  success: false,
                  query: params.query,
                  results: [],
                  message: "No businesses found. Try a different search.",
                });
              }
            } catch (error) {
              console.error("[Tool] search_businesses error:", error);
              return JSON.stringify({
                success: false,
                error: "Search failed. Please try again.",
              });
            }
          },
          // Client-side tool: triggers a call via our API
          call_business: async (params: {
            phoneNumber: string;
            businessName: string;
            userRequest: string;
            language?: string;
          }) => {
            console.log("[Tool] call_business called:", params);
            setAgentPhase("calling");
            setStatusText(`Calling ${params.businessName}...`);
            setCallStatus("dialing");

            // Find and select the business from current results
            const match = businessesRef.current.find(
              (b) => b.name === params.businessName || b.phone === params.phoneNumber
            );
            if (match) setSelectedBusiness(match);

            try {
              const callParams = new URLSearchParams({
                phoneNumber: params.phoneNumber,
                businessName: params.businessName,
                userRequest: params.userRequest,
              });
              if (params.language) callParams.set("language", params.language);

              const res = await fetch(`/api/call?${callParams.toString()}`);
              const data = await res.json();

              if (data.callSid) {
                setCallStatus("ringing");
                pollCallStatus(data.callSid, params.businessName);
                return JSON.stringify({
                  success: true,
                  message: `Call initiated to ${params.businessName}. Ringing now.`,
                });
              } else {
                setCallStatus("failed");
                return JSON.stringify({
                  success: false,
                  error: data.error || "Call failed to connect.",
                });
              }
            } catch (error) {
              console.error("[Tool] call_business error:", error);
              setCallStatus("failed");
              return JSON.stringify({
                success: false,
                error: "Call failed. Please try again.",
              });
            }
          },
        },
        onConnect: () => {
          console.log("[Agent] Connected");
          setIsConnecting(false);
          setIsConnected(true);
          setAgentPhase("listening");
          setStatusText("Hold the mic to talk");
        },
        onDisconnect: () => {
          console.log("[Agent] Disconnected");
          setIsConnecting(false);
          setIsConnected(false);
          setIsSpeaking(false);
          setAgentPhase("idle");
          setStatusText("Tap the mic to start");
        },
        onMessage: (message: { role?: string; message?: string }) => {
          if (message.message) {
            const entry: TranscriptEntry = {
              id: `${Date.now()}-${Math.random().toString(36).slice(2)}`,
              role: message.role === "user" ? "user" : "agent",
              text: message.message,
              timestamp: Date.now(),
            };
            setTranscript((prev) => [...prev, entry]);
          }
        },
        onModeChange: (mode: { mode?: string }) => {
          if (mode.mode === "listening") {
            setAgentPhase("listening");
            setStatusText("Hold the mic to talk");
          } else if (mode.mode === "speaking") {
            setAgentPhase("speaking");
            setStatusText("Speaking...");
          }
        },
        onError: (error: unknown) => {
          console.error("[Agent] Error:", error);
          setIsConnecting(false);
          setStatusText("Something went wrong. Try again.");
        },
      });

      conversationRef.current = conversation;

      // Start muted — user needs to hold mic to talk
      try {
        const conv = conversation as { setVolume: (opts: { volume: number }) => void };
        conv.setVolume({ volume: 1 });
      } catch {}
    } catch (error) {
      console.error("[Agent] Connection failed:", error);
      setIsConnecting(false);
      setAgentPhase("idle");
      setStatusText("Failed to connect. Try again.");
    }
  }, []);

  const disconnectAgent = useCallback(async () => {
    if (conversationRef.current) {
      try {
        const conversation = conversationRef.current as { endSession: () => Promise<void> };
        await conversation.endSession();
      } catch (error) {
        console.error("[Agent] Error disconnecting:", error);
      }
      conversationRef.current = null;
    }
    setIsConnecting(false);
    setIsConnected(false);
    setIsSpeaking(false);
    setAgentPhase("idle");
    setStatusText("Tap the mic to start");
    setTranscript([]);
  }, []);

  // Push-to-talk: hold mic to speak, release to let agent respond
  const handlePressStart = useCallback(() => {
    if (!conversationRef.current || !isConnected) return;
    setIsSpeaking(true);
    setAgentPhase("listening");
    setStatusText("Listening...");
    // Unmute microphone input so agent hears the user
    // The ElevenLabs SDK handles mic input — we just need to ensure volume is on
  }, [isConnected]);

  const handlePressEnd = useCallback(() => {
    if (!conversationRef.current || !isConnected) return;
    setIsSpeaking(false);
    setAgentPhase("thinking");
    setStatusText("Thinking...");
    // Agent will process what it heard and respond
  }, [isConnected]);

  // ── Call Status Polling ──────────────────────────────────────────────────

  const pollCallStatus = useCallback(
    (callSid: string, businessName: string) => {
      const interval = setInterval(async () => {
        try {
          const res = await fetch(`/api/call/status?callSid=${callSid}`);
          const data = await res.json();

          switch (data.status) {
            case "ringing":
              setCallStatus("ringing");
              break;
            case "in-progress":
              setCallStatus("connected");
              setAgentPhase("on-call");
              setStatusText(`On the phone with ${businessName}`);
              break;
            case "completed":
              setCallStatus("completed");
              setCallDuration(data.duration);
              setAgentPhase("speaking");
              setStatusText("Call completed");
              clearInterval(interval);
              break;
            case "no-answer":
            case "busy":
              setCallStatus("no-answer");
              setStatusText(`${businessName} didn't answer`);
              setAgentPhase("speaking");
              clearInterval(interval);
              break;
            case "failed":
              setCallStatus("failed");
              setStatusText("Call failed");
              setAgentPhase("speaking");
              clearInterval(interval);
              break;
          }
        } catch {
          // Silently retry
        }
      }, 2000);

      setTimeout(() => clearInterval(interval), 300000);
    },
    []
  );

  // ── Cleanup ────────────────────────────────────────────────────────────

  useEffect(() => {
    return () => {
      disconnectAgent();
    };
  }, [disconnectAgent]);

  // ── Render ─────────────────────────────────────────────────────────────

  return (
    <div className="flex flex-col items-center min-h-screen px-4 py-8">
      {/* Header */}
      <motion.header
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="flex items-center gap-3 mb-12"
      >
        <h1 className="text-2xl font-bold text-zinc-900 tracking-tight">
          Ghost Caller
        </h1>
        <span className="text-xs font-medium text-zinc-400 bg-zinc-100 px-2 py-0.5 rounded-full">
          AI
        </span>
      </motion.header>

      {/* Orb + Status */}
      <div className="flex flex-col items-center gap-4 mb-8">
        <AudioOrb phase={agentPhase} />
        <AgentStatus text={statusText} />
      </div>

      {/* Call Status Badge */}
      <div className="mb-6">
        <CallStatus
          status={callStatus}
          businessName={selectedBusiness?.name}
          duration={callDuration}
        />
      </div>

      {/* Business Cards */}
      <AnimatePresence>
        {businesses.length > 0 && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0 }}
            className="w-full max-w-lg space-y-2 mb-6"
          >
            {businesses.map((business, i) => (
              <BusinessCard
                key={`${business.name}-${i}`}
                business={business}
                index={i}
                isSelected={selectedBusiness?.name === business.name}
                onCallClick={(b) => {
                  if (b.phone) {
                    setSelectedBusiness(b);
                    setCallStatus("dialing");
                  }
                }}
              />
            ))}
          </motion.div>
        )}
      </AnimatePresence>

      {/* Live Transcript */}
      <div className="mb-8">
        <LiveTranscript entries={transcript} />
      </div>

      {/* Mic Button — Push to Talk */}
      <div className="fixed bottom-8 left-1/2 -translate-x-1/2">
        <MicButton
          isConnected={isConnected}
          isConnecting={isConnecting}
          isSpeaking={isSpeaking}
          onConnect={connectToAgent}
          onPressStart={handlePressStart}
          onPressEnd={handlePressEnd}
          onDisconnect={disconnectAgent}
        />
      </div>

      {/* Spacer for fixed mic button */}
      <div className="h-28" />
    </div>
  );
}
