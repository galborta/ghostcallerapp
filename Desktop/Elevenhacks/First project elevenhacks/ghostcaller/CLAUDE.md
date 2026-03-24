# Ghost Caller — An AI That Calls Any Business So You Don't Have To

## Purpose & Scope

**The pitch:** "I built an AI that calls businesses for you. Tell it what you need, it finds the number, makes the call, and reports back — in any language."

Ghost Caller is a web app where you speak to a voice agent (ElevenAgents), tell it what you need, and the agent:
1. Uses **Firecrawl Search** to find the business (name, phone, ratings, reviews)
2. Shows **Google Maps-style business cards** with star ratings, address, phone
3. Makes a **real phone call** via **ElevenLabs + Twilio native integration**
4. An ElevenLabs AI agent conducts the actual phone conversation — **in any language**
5. Reports back with the real answer

### The "Wow" Moment for Judges
The agent calls a French restaurant IN FRENCH, has a real conversation, while you watch business cards and status updates on screen. The user doesn't speak French — the AI does it for them.

### What's OUT of Scope
- Mobile native app (web only)
- Multiple simultaneous calls
- Call recording/storage (privacy)
- Payment processing
- User accounts/auth

---

## Tech Stack

```
Frontend        Next.js 15 (App Router, TypeScript) + Tailwind CSS v4
Animations      Framer Motion v12 (audio-reactive orb, transitions)
Voice Agent     ElevenLabs ElevenAgents (conversational AI, WebSocket SDK)
Web Search      Firecrawl Search API (find businesses)
Phone Calls     ElevenLabs + Twilio native integration (real AI phone calls)
Backend         Next.js API routes (orchestration, keeps keys server-side)
Deployment      Vercel (auto-deploy from GitHub)
Repo            github.com/galborta/ghostcallerapp
Live URL        https://ghostcallerapp.vercel.app
```

---

## Architecture

```
User speaks to ElevenAgent via browser (WebSocket)
         │
         ▼
   ElevenAgent (voice conversation)
   "Find me a Thai restaurant in Palermo Buenos Aires"
         │
         ▼
   Client Tool: search_businesses
   → Runs IN THE BROWSER (not webhook)
   → Calls /api/search → Firecrawl Search API
   → Populates BusinessCard UI with results
   → Returns data to agent so it can speak about them
         │
         ▼
   Agent summarizes findings (voice) + user SEES cards on screen
   "Found 3 spots: Sottovoce 4.5 stars, Il Ballo 4.3, Nonna Giovanna 4.2"
         │
         ▼
   User taps "Call" on a card OR tells agent to call
         │
         ▼
   Client Tool: call_business
   → Calls /api/call → ElevenLabs Outbound Call API
   → POST /v1/convai/twilio/outbound-call
   → ElevenLabs agent calls the business via Twilio
   → Agent conducts real conversation IN ANY LANGUAGE
         │
         ▼
   Call status updates shown in UI (dialing → ringing → connected → completed)
   Agent reports back: "They have a table at 7:15"
```

### Key Design Decisions

1. **Client tools, not webhooks** — Tools run in the browser so we can populate UI (cards, status) AND return data to the agent. Prevents the agent from reading tool JSON out loud.

2. **Push-to-talk mic** — User holds mic to speak, releases to let agent respond. Walkie-talkie style. Prevents accidental disconnects and saves ElevenLabs credits.

3. **ElevenLabs outbound calls, not raw Twilio** — Uses ElevenLabs' native Twilio integration so the AI agent handles the phone conversation in real-time. No TwiML scripts.

4. **No scrapeOptions on Firecrawl** — Removed `scrapeOptions: { formats: ["markdown"] }` because it caused 5-10 second delays per search, making webhook calls timeout. Basic search results have enough data.

5. **Enriched search queries** — Appends "phone number address reviews" to search queries for better business data extraction.

---

## Environment Variables

```bash
# ── ElevenLabs ──────────────────────────────────────────────────
ELEVENLABS_API_KEY=xi-...              # Server-side only
NEXT_PUBLIC_ELEVENLABS_AGENT_ID=...    # Agent ID (public, used by SDK)
ELEVENLABS_PHONE_NUMBER_ID=phnum_...   # Imported Twilio number ID

# ── Firecrawl ──────────────────────────────────────────────────
FIRECRAWL_API_KEY=fc-...               # Server-side only

# ── Twilio (used by ElevenLabs native integration) ─────────────
TWILIO_ACCOUNT_SID=AC...               # Starts with AC
TWILIO_AUTH_TOKEN=...
TWILIO_PHONE_NUMBER=+1...              # US number

# ── App ────────────────────────────────────────────────────────
NEXT_PUBLIC_APP_URL=https://ghostcallerapp.vercel.app
```

All env vars are set in **Vercel** → Project Settings → Environment Variables.

---

## Repository Structure

```
ghostcaller/
├── app/
│   ├── page.tsx                    # Main page, renders GhostCaller
│   ├── layout.tsx                  # Root layout + fonts
│   ├── globals.css                 # Tailwind v4 + custom styles
│   └── api/
│       ├── agent/route.ts          # Returns signed URL for ElevenAgent WebSocket
│       ├── search/route.ts         # GET+POST — Firecrawl Search proxy (CORS headers)
│       ├── call/
│       │   ├── route.ts            # GET+POST — ElevenLabs outbound call via Twilio
│       │   ├── status/route.ts     # GET (poll) + POST (Twilio webhook) call status
│       │   └── twiml/route.ts      # TwiML fallback (legacy, not used with native integration)
│
├── components/
│   ├── GhostCaller.tsx             # Main app container + client tools + state management
│   ├── AudioOrb.tsx                # Framer Motion phase-based animated orb
│   ├── BusinessCard.tsx            # Google Maps-style card with SVG stars, icons
│   ├── LiveTranscript.tsx          # Auto-scrolling conversation transcript
│   ├── CallStatus.tsx              # Call progress badge (dialing/ringing/connected)
│   ├── AgentStatus.tsx             # Animated status text below orb
│   └── MicButton.tsx               # Push-to-talk mic with visual states
│
├── lib/
│   ├── firecrawl.ts                # Firecrawl Search client, phone/rating extraction
│   ├── twilio.ts                   # ElevenLabs outbound call API (not raw Twilio)
│   ├── elevenlabs.ts               # Agent config, system prompt, signed URL
│   └── types.ts                    # Shared TypeScript types
│
├── CLAUDE.md                       # This file — project source of truth
├── package.json                    # @elevenlabs/client@^0.15.2, NOT 1.0.0
├── tsconfig.json
├── next.config.ts
└── postcss.config.mjs
```

---

## Component Details

### GhostCaller.tsx (Main Container)
- Manages all state: agent phase, connection, transcript, businesses, call status
- Registers **clientTools** with ElevenLabs session:
  - `search_businesses` → calls `/api/search`, populates BusinessCard[], returns results to agent
  - `call_business` → calls `/api/call`, updates call status, starts polling
- Uses `businessesRef` to avoid stale closures in tool handlers
- Push-to-talk: `handlePressStart` / `handlePressEnd`

### MicButton.tsx (Push-to-Talk)
- **Tap** (when disconnected) → connects to agent
- **Hold** (when connected) → user speaking (red, pulse)
- **Release** → agent processes + responds
- **X button** → end session (appears when connected, not holding)
- Hint text: "Tap to start" / "Hold to talk" / "Release to send" / "Connecting..."

### BusinessCard.tsx (Google Maps Style)
- SVG star ratings (full, half, empty) — not emoji
- SVG location pin icon + address
- SVG phone icon + number (font-mono)
- Cuisine/price tags as rounded pills
- "Call" button with phone icon
- Green highlight when selected/calling
- Framer Motion staggered entry animation

### AudioOrb.tsx
- Phase-based colors: idle=gray, listening=indigo, thinking=purple, searching=amber, speaking=indigo, calling=green, on-call=green
- No audioLevel prop — purely phase-driven animations

---

## ElevenLabs Dashboard Configuration

### System Prompt (MUST match lib/elevenlabs.ts)
```
You are Ghost Caller — an AI that finds businesses and calls them for users.
Be fast, direct, and action-oriented.

CRITICAL RULES:
0. NEVER read tool calls, URLs, JSON, or technical syntax out loud.
1. SEARCH IMMEDIATELY when user mentions business type + location.
2. Keep responses SHORT. Max 2 sentences.
3. Present results briefly: name, rating, one detail. "Want me to call one?"
4. NEVER LIE ABOUT CALLS — only report what the tool actually returns.
5. Speak any language needed for the call.
```

### Tools (MUST be "client" type, not "webhook")
- `search_businesses` — type: client, expects_response: true, timeout: 20s
- `call_business` — type: client, expects_response: true, timeout: 30s

### Phone Number
- Twilio number imported via Phone Numbers → Import from Twilio
- Assigned to Ghost Caller agent
- Phone number ID: `phnum_6801kmcd6zhte5pa63rwdf4p3c1m`

---

## API Integration Details

### Firecrawl Search
- **Endpoint:** `POST https://api.firecrawl.dev/v1/search`
- **NO scrapeOptions** — removed to avoid webhook timeout
- **Query enrichment:** `${query} in ${location} phone number address reviews`
- **Phone extraction:** Regex supports international formats (+54, +33, etc.)
- **Cost:** 2 credits per 10 results

### ElevenLabs Outbound Call
- **Endpoint:** `POST https://api.elevenlabs.io/v1/convai/twilio/outbound-call`
- **Headers:** `xi-api-key`, `Content-Type: application/json`
- **Body:** `{ agent_id, agent_phone_number_id, to_number, conversation_initiation_client_data }`
- **Per-call prompt override:** Sends specific instructions for each call (language, request)
- **The agent conducts the real phone conversation** — in any language

### ElevenLabs Signed URL (WebSocket)
- **Endpoint:** `GET https://api.elevenlabs.io/v1/convai/conversation/get-signed-url?agent_id=...`
- **Headers:** `xi-api-key`
- **Returns:** `{ signed_url }` for browser WebSocket connection

---

## Known Issues & Fixes

| Issue | Fix |
|-------|-----|
| `@elevenlabs/client@^1.0.0` not found | Use `^0.15.2` — 1.0.0 doesn't exist on npm |
| Firecrawl webhook timeout | Removed `scrapeOptions` — basic search is fast enough |
| Agent reads tool JSON out loud | Switched from webhook to client tools + prompt rule 0 |
| Agent fabricates call results | Added strict rule 4: never lie about calls |
| "Palermo" returns US results | Changed query to `${query} in ${location}` instead of `near` |
| Mic disconnect burns credits | Changed to push-to-talk (hold to speak, release to send) |
| Phone regex misses international | Updated regex for +XX format with 1-4 digit area codes |

---

## Demo Script (90 seconds)

### Hook (0-5s)
**"My girlfriend is in France. She doesn't speak French. So I built an AI that calls restaurants for her — in French."**

### Setup (5-15s)
Show the clean UI. "You just tell Ghost Caller what you need."

### Demo: Search (15-30s)
Speak: "Find me Italian restaurants in Palermo, Buenos Aires."
Show: Orb animates → business cards pop up with star ratings, addresses, phone numbers.

### Demo: The Call (30-65s)
Tap "Call" on a card.
Show: Call status changes: Dialing → Ringing → Connected
**This is the WOW moment** — an AI agent is having a REAL phone conversation with the restaurant.

### Multilingual Demo (65-80s)
"Now watch this — same thing, but in French."
Show: Agent calls a French restaurant, speaks fluent French.

### Closer (80-90s)
"Ghost Caller. Never make an awkward phone call again. Built with ElevenAgents and Firecrawl for #ElevenHacks."

---

## Build Status

- [x] GitHub repo + CLAUDE.md
- [x] Next.js 15 scaffold + Tailwind + Framer Motion
- [x] Firecrawl Search integration (no scrapeOptions, enriched queries)
- [x] ElevenAgents setup (agent config, voice, system prompt)
- [x] Client tools registered (search_businesses, call_business)
- [x] ElevenLabs + Twilio native integration for real AI phone calls
- [x] Main UI: AudioOrb + AgentStatus + push-to-talk MicButton
- [x] BusinessCard component (SVG stars, icons, call button)
- [x] LiveTranscript component
- [x] CallStatus component
- [x] Deploy to Vercel
- [ ] Verify business cards appear on search (check browser console)
- [ ] End-to-end test: speak → search → cards → tap call → real phone call
- [ ] Test multilingual call (French restaurant)
- [ ] UI polish pass (animations, transitions, spacing)
- [ ] Record demo video
- [ ] Edit in CapCut (captions, music, trim)
- [ ] Post to X, LinkedIn, Instagram, TikTok
- [ ] Submit to ElevenHacks (deadline: Thursday March 26, 17:00)

---

## Critical Invariants

- **Never expose API keys client-side** — all Firecrawl and Twilio calls go through Next.js API routes
- **Client tools, not webhooks** — prevents agent from reading JSON out loud, enables UI updates
- **Never lie about calls** — agent can only report what the tool actually returns
- **Firecrawl before calling** — always search first to have context
- **Push-to-talk** — hold mic to speak, release to let agent respond
- **ElevenLabs package is ^0.15.2** — NOT 1.0.0 (doesn't exist)

---

**Last Updated:** March 23, 2026
**Status:** Core integration complete — testing & polish phase
