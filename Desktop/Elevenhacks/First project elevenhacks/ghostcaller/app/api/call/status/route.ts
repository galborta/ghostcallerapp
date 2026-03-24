import { NextRequest, NextResponse } from "next/server";

/**
 * POST /api/call/status
 * Twilio status callback webhook.
 * Receives call status updates (initiated, ringing, answered, completed).
 *
 * In production, this would push updates via WebSocket/SSE to the frontend.
 * For the hackathon demo, we log status and could use polling or SSE.
 */

// In-memory call status store (for demo — would use Redis/DB in production)
const callStatuses = new Map<
  string,
  { status: string; duration?: number; timestamp: number }
>();

export async function POST(req: NextRequest) {
  try {
    const formData = await req.formData();

    const callSid = formData.get("CallSid") as string;
    const callStatus = formData.get("CallStatus") as string;
    const duration = formData.get("CallDuration") as string | null;

    console.log(`[Call Status] ${callSid}: ${callStatus}${duration ? ` (${duration}s)` : ""}`);

    if (callSid) {
      callStatuses.set(callSid, {
        status: callStatus,
        duration: duration ? parseInt(duration) : undefined,
        timestamp: Date.now(),
      });
    }

    // Twilio expects 200 OK with empty TwiML or plain response
    return new NextResponse("<Response/>", {
      status: 200,
      headers: { "Content-Type": "text/xml" },
    });
  } catch (error) {
    console.error("[/api/call/status] Error:", error);
    return new NextResponse("<Response/>", {
      status: 200,
      headers: { "Content-Type": "text/xml" },
    });
  }
}

/**
 * GET /api/call/status?callSid=...
 * Poll for call status (frontend uses this until WebSocket is set up).
 */
export async function GET(req: NextRequest) {
  const callSid = req.nextUrl.searchParams.get("callSid");

  if (!callSid) {
    return NextResponse.json({ error: "callSid required" }, { status: 400 });
  }

  const status = callStatuses.get(callSid);

  if (!status) {
    return NextResponse.json({ status: "unknown" });
  }

  return NextResponse.json(status);
}
