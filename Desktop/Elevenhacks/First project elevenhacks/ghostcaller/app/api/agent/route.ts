import { NextResponse } from "next/server";
import { getSignedAgentUrl } from "@/lib/elevenlabs";

/**
 * GET /api/agent
 * Returns a signed URL for connecting to the ElevenAgent via WebSocket.
 * This keeps the ElevenLabs API key server-side.
 */
export async function GET() {
  try {
    const signedUrl = await getSignedAgentUrl();

    return NextResponse.json({ signedUrl });
  } catch (error) {
    console.error("[/api/agent] Error:", error);
    return NextResponse.json(
      {
        error:
          error instanceof Error
            ? error.message
            : "Failed to get agent connection",
      },
      { status: 500 }
    );
  }
}
