// ── Business Search Results (from Firecrawl) ─────────────────────────────────

export interface Business {
  name: string;
  phone: string | null;
  address: string | null;
  rating: number | null;
  reviewCount: number | null;
  hours: string | null;
  cuisine: string | null;
  priceRange: string | null;
  website: string | null;
  snippet: string | null;
  sourceUrl: string;
}

export interface SearchResult {
  businesses: Business[];
  query: string;
  timestamp: number;
}

// ── Call State ────────────────────────────────────────────────────────────────

export type CallStatus =
  | "idle"
  | "searching"
  | "found"
  | "dialing"
  | "ringing"
  | "connected"
  | "completed"
  | "failed"
  | "no-answer";

export interface CallState {
  status: CallStatus;
  business: Business | null;
  userRequest: string | null;
  transcript: TranscriptEntry[];
  summary: string | null;
  callSid: string | null;
  duration: number | null;
}

// ── Transcript ───────────────────────────────────────────────────────────────

export type SpeakerRole = "user" | "agent" | "business";

export interface TranscriptEntry {
  id: string;
  role: SpeakerRole;
  text: string;
  timestamp: number;
  language?: string;
}

// ── Agent State ──────────────────────────────────────────────────────────────

export type AgentPhase =
  | "idle"
  | "listening"
  | "thinking"
  | "searching"
  | "speaking"
  | "calling"
  | "on-call";

export interface AgentState {
  phase: AgentPhase;
  statusText: string;
  isMuted: boolean;
}

// ── API Payloads ─────────────────────────────────────────────────────────────

export interface SearchRequest {
  query: string;
  location?: string;
  limit?: number;
}

export interface CallRequest {
  phoneNumber: string;
  businessName: string;
  userRequest: string;
  language?: string; // e.g. "fr" for French — the multilingual magic
}

export interface CallStatusUpdate {
  callSid: string;
  status: string;
  duration?: number;
}
