import { CallRequest } from "./types";

/**
 * Normalize a phone number to E.164 format required by Twilio.
 * Handles formats like "+54 11 4322-5678", "(011) 4322-5678", "011-4322-5678".
 * If the number already starts with +, strip everything non-numeric except the +.
 * Otherwise, assume it needs a + prefix after stripping non-numerics.
 */
function normalizePhoneNumber(raw: string): string {
  const trimmed = raw.trim();
  if (trimmed.startsWith("+")) {
    // Keep the + and strip everything else that isn't a digit
    return "+" + trimmed.slice(1).replace(/\D/g, "");
  }
  // No + prefix — strip non-digits and prepend +
  // Caller must ensure the country code is included in the number
  return "+" + trimmed.replace(/\D/g, "");
}

/**
 * Initiate an outbound call via ElevenLabs + Twilio native integration.
 *
 * Instead of using raw Twilio TwiML, we use ElevenLabs' outbound call API.
 * This connects the call to an ElevenLabs agent that conducts a real-time
 * AI conversation with the business — in any language.
 *
 * API: POST https://api.elevenlabs.io/v1/convai/twilio/outbound-call
 */
export async function initiateCall(request: CallRequest): Promise<{
  callSid: string | null;
  conversationId: string | null;
  status: string;
}> {
  const elevenLabsApiKey = process.env.ELEVENLABS_API_KEY;
  const agentId = process.env.NEXT_PUBLIC_ELEVENLABS_AGENT_ID;
  const phoneNumberId = process.env.ELEVENLABS_PHONE_NUMBER_ID;

  if (!elevenLabsApiKey || !agentId || !phoneNumberId) {
    throw new Error(
      "ElevenLabs credentials not configured. Need ELEVENLABS_API_KEY, NEXT_PUBLIC_ELEVENLABS_AGENT_ID, and ELEVENLABS_PHONE_NUMBER_ID."
    );
  }

  // Normalize to E.164 — Twilio rejects numbers with spaces, dashes, or parens
  const toNumber = normalizePhoneNumber(request.phoneNumber);
  console.log(`[initiateCall] Raw number: "${request.phoneNumber}" → Normalized: "${toNumber}"`);

  // Build the caller agent's prompt override for this specific call
  const callerPrompt = buildCallerPrompt(request);

  const requestBody = {
    agent_id: agentId,
    agent_phone_number_id: phoneNumberId,
    to_number: toNumber,
    conversation_initiation_client_data: {
      conversation_config_override: {
        agent: {
          prompt: {
            prompt: callerPrompt,
          },
          language: request.language ?? "en",
        },
      },
    },
  };

  console.log("[initiateCall] Sending to ElevenLabs:", JSON.stringify(requestBody, null, 2));

  const response = await fetch(
    "https://api.elevenlabs.io/v1/convai/twilio/outbound-call",
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "xi-api-key": elevenLabsApiKey,
      },
      body: JSON.stringify(requestBody),
    }
  );

  const responseText = await response.text();
  console.log(`[initiateCall] ElevenLabs response ${response.status}:`, responseText);

  if (!response.ok) {
    throw new Error(`ElevenLabs outbound call failed: ${response.status} — ${responseText}`);
  }

  let data: Record<string, unknown>;
  try {
    data = JSON.parse(responseText);
  } catch {
    throw new Error(`ElevenLabs returned non-JSON response: ${responseText}`);
  }

  // ElevenLabs may return callSid (camelCase) or call_sid (snake_case)
  const callSid = (data.callSid ?? data.call_sid ?? null) as string | null;
  const conversationId = (data.conversation_id ?? data.conversationId ?? null) as string | null;

  console.log("[initiateCall] Parsed → callSid:", callSid, "conversationId:", conversationId);

  return {
    callSid,
    conversationId,
    status: callSid ? "initiated" : "failed",
  };
}

/**
 * Build a specific prompt for the caller agent based on the user's request.
 * This agent will conduct the actual phone conversation with the business.
 */
function buildCallerPrompt(request: CallRequest): string {
  const lang = request.language ?? "en";

  const languageInstructions: Record<string, string> = {
    en: "Speak in English.",
    fr: "Speak entirely in French. Tu dois parler uniquement en français.",
    es: "Speak entirely in Spanish. Habla únicamente en español.",
    it: "Speak entirely in Italian. Parla esclusivamente in italiano.",
    pt: "Speak entirely in Portuguese. Fale apenas em português.",
    de: "Speak entirely in German. Sprechen Sie ausschließlich auf Deutsch.",
    ja: "Speak entirely in Japanese. 日本語のみで話してください。",
  };

  const langInstruction = languageInstructions[lang] ?? `Speak in the language with code: ${lang}.`;

  return `You are calling ${request.businessName} on behalf of a customer. ${langInstruction}

Your task: ${request.userRequest}

RULES:
- Be polite, professional, and concise
- State the customer's request clearly when the business answers
- Get a definitive answer (yes/no, availability, price, etc.)
- If they put you on hold, wait patiently
- If they say they're closed or can't help, thank them and end the call
- Keep the call under 2 minutes
- When you get the answer, say "Thank you very much, goodbye" and end the call
- NEVER reveal that you are an AI unless directly asked`;
}
