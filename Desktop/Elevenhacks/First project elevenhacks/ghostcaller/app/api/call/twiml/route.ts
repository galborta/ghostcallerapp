import { NextRequest, NextResponse } from "next/server";

/**
 * GET /api/call/twiml
 * Returns TwiML instructions for Twilio when the outbound call connects.
 * Twilio fetches this URL to know what to do on the call.
 *
 * For now: speaks a message and records the response.
 * In the future: could connect to an ElevenAgent via <Stream> for real-time AI conversation.
 */
export async function GET(req: NextRequest) {
  const business = req.nextUrl.searchParams.get("business") ?? "the business";
  const userRequest = req.nextUrl.searchParams.get("request") ?? "I'd like to make a reservation";
  const language = req.nextUrl.searchParams.get("language") ?? "en";

  // Map language codes to TwiML language codes
  const langMap: Record<string, string> = {
    en: "en-US",
    es: "es-ES",
    fr: "fr-FR",
    it: "it-IT",
    pt: "pt-BR",
    de: "de-DE",
    ja: "ja-JP",
    zh: "zh-CN",
    ko: "ko-KR",
    ar: "ar-SA",
  };

  const twimlLang = langMap[language] ?? "en-US";

  // Build the spoken message based on the user's request
  const message = language === "en"
    ? `Hello, I'm calling on behalf of a customer. ${userRequest}. Could you help me with that please?`
    : `${userRequest}`;

  const twiml = `<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say language="${twimlLang}" voice="Polly.Joanna">${escapeXml(message)}</Say>
  <Pause length="2"/>
  <Say language="${twimlLang}" voice="Polly.Joanna">Thank you, goodbye.</Say>
  <Hangup/>
</Response>`;

  return new NextResponse(twiml, {
    headers: {
      "Content-Type": "application/xml",
    },
  });
}

export async function POST(req: NextRequest) {
  // Twilio sometimes POSTs to TwiML URLs
  return GET(req);
}

function escapeXml(str: string): string {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&apos;");
}
