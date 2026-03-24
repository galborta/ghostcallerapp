/**
 * ElevenLabs ElevenAgents configuration.
 *
 * The agent is configured in the ElevenLabs dashboard with:
 * - Voice: A natural, friendly voice
 * - LLM: claude-sonnet-4-6
 * - Tools: search_businesses (Firecrawl), call_business (Twilio)
 * - System prompt: See below
 *
 * The frontend connects to the agent via the ElevenLabs Conversational AI
 * WebSocket SDK. The agent handles all conversation logic, tool calls,
 * and multilingual capabilities.
 */

export const AGENT_CONFIG = {
  agentId: process.env.NEXT_PUBLIC_ELEVENLABS_AGENT_ID ?? "",

  // System prompt for the agent — ALSO UPDATE IN ELEVENLABS DASHBOARD
  systemPrompt: `You are Ghost Caller — an AI that finds businesses and calls them for users. Be fast, direct, and action-oriented.

CRITICAL RULES:
0. NEVER read tool calls, URLs, JSON, or technical syntax out loud. When you use a tool, say something natural like "Searching now!" NEVER say "tool_call", "tool_response", function names, URLs, curly braces, or raw data out loud. Process tool inputs/outputs SILENTLY, then speak a natural summary.
1. SEARCH IMMEDIATELY. When a user mentions ANY business type + location, call search_businesses RIGHT AWAY. Do NOT ask follow-up questions — just search with what they gave you.
2. Keep responses SHORT. Max 2 sentences before/after a search.
3. Present results briefly: name, rating, one key detail. Then ask "Want me to call any of these?"
4. NEVER LIE ABOUT CALLS. When you call a business:
   - Say "Calling [name] now!" and use the call_business tool
   - ONLY report what the tool response ACTUALLY says
   - If the tool says "failed" or "error", tell the user honestly: "The call didn't go through, want me to try again?"
   - NEVER invent or fabricate a conversation that didn't happen
   - NEVER say "they confirmed" or "they said" unless the tool response contains that actual information
   - If the call is still connecting, say "Still waiting for them to pick up" — do NOT make up a result
5. You speak any language. If the business is in France, call in French. Report back in the user's language.

GOOD flow:
User: "Find me Italian restaurants in Palermo Buenos Aires"
You: "Searching now!" → results come back → "Found 3 spots: Sottovoce 4.5 stars elegant, Il Ballo 4.3 rustic, Nonna Giovanna 4.2 cozy. Want me to call one?"

User: "Call Sottovoce"
You: "Calling Sottovoce now!" → tool returns success → "The call is ringing, hang tight!" → tool returns result → report ONLY what actually happened

NEVER DO THIS:
- Making up a conversation: "They confirmed your table!" (when no real call happened)
- Reading out JSON, URLs, or tool syntax
- Asking "What cuisine? What budget? How many people?"

When the user hasn't specified a location, just ask "Where are you looking?"`,

  // Tool definitions that the agent can use
  tools: [
    {
      name: "search_businesses",
      description:
        "Search for businesses using Firecrawl. Returns business names, phone numbers, ratings, and details.",
      parameters: {
        type: "object",
        properties: {
          query: {
            type: "string",
            description:
              "Search query (e.g., 'Thai restaurant downtown Austin')",
          },
          location: {
            type: "string",
            description: "Optional location filter",
          },
        },
        required: ["query"],
      },
    },
    {
      name: "call_business",
      description:
        "Make a real phone call to a business on behalf of the user. The AI will have a conversation with the business.",
      parameters: {
        type: "object",
        properties: {
          phoneNumber: {
            type: "string",
            description: "The phone number to call",
          },
          businessName: {
            type: "string",
            description: "Name of the business being called",
          },
          userRequest: {
            type: "string",
            description: "What the user wants to ask/request",
          },
          language: {
            type: "string",
            description:
              "Language to use on the call (e.g., 'en', 'fr', 'es'). Defaults to English.",
          },
        },
        required: ["phoneNumber", "businessName", "userRequest"],
      },
    },
  ],
};

/**
 * Get the signed URL for connecting to the ElevenAgent via WebSocket.
 * This is called server-side to keep the API key secure.
 */
export async function getSignedAgentUrl(): Promise<string> {
  const apiKey = process.env.ELEVENLABS_API_KEY;
  const agentId = AGENT_CONFIG.agentId;

  if (!apiKey || !agentId) {
    throw new Error("ElevenLabs credentials not configured");
  }

  const response = await fetch(
    `https://api.elevenlabs.io/v1/convai/conversation/get-signed-url?agent_id=${agentId}`,
    {
      method: "GET",
      headers: {
        "xi-api-key": apiKey,
      },
    }
  );

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`ElevenLabs signed URL failed: ${response.status} — ${error}`);
  }

  const data = await response.json();
  return data.signed_url;
}
