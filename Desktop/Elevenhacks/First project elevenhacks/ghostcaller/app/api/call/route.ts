import { NextRequest, NextResponse } from "next/server";
import { initiateCall } from "@/lib/twilio";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

export async function OPTIONS() {
  return NextResponse.json({}, { headers: corsHeaders });
}

/**
 * GET /api/call?phoneNumber=...&businessName=...&userRequest=...&language=...
 * Called by client tools from the browser.
 * Triggers an outbound call via ElevenLabs + Twilio.
 * The ElevenLabs agent conducts the real-time conversation with the business.
 */
export async function GET(req: NextRequest) {
  try {
    const phoneNumber = req.nextUrl.searchParams.get("phoneNumber");
    const businessName = req.nextUrl.searchParams.get("businessName");
    const userRequest = req.nextUrl.searchParams.get("userRequest");
    const language = req.nextUrl.searchParams.get("language") ?? "en";

    if (!phoneNumber || !businessName || !userRequest) {
      return NextResponse.json(
        { error: "phoneNumber, businessName, and userRequest are required" },
        { status: 400, headers: corsHeaders }
      );
    }

    const result = await initiateCall({
      phoneNumber,
      businessName,
      userRequest,
      language,
    });

    return NextResponse.json(result, { headers: corsHeaders });
  } catch (error) {
    console.error("[/api/call GET] Error:", error);
    return NextResponse.json(
      { error: error instanceof Error ? error.message : "Call failed" },
      { status: 500, headers: corsHeaders }
    );
  }
}

/**
 * POST /api/call
 * Same as GET but with JSON body.
 */
export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.phoneNumber || !body.businessName || !body.userRequest) {
      return NextResponse.json(
        { error: "phoneNumber, businessName, and userRequest are required" },
        { status: 400, headers: corsHeaders }
      );
    }

    const result = await initiateCall({
      phoneNumber: body.phoneNumber,
      businessName: body.businessName,
      userRequest: body.userRequest,
      language: body.language ?? "en",
    });

    return NextResponse.json(result, { headers: corsHeaders });
  } catch (error) {
    console.error("[/api/call POST] Error:", error);
    return NextResponse.json(
      { error: error instanceof Error ? error.message : "Call failed" },
      { status: 500, headers: corsHeaders }
    );
  }
}
