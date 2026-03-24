import { NextRequest, NextResponse } from "next/server";
import { searchBusinesses } from "@/lib/firecrawl";
import { SearchRequest } from "@/lib/types";

// CORS headers for client tool requests
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

/**
 * GET /api/search?query=...&location=...&limit=5
 * Called by the browser-side client tool (search_businesses).
 */
export async function GET(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url);
    const query = searchParams.get("query");
    const location = searchParams.get("location") || undefined;
    const limit = parseInt(searchParams.get("limit") ?? "5", 10);

    if (!query) {
      return NextResponse.json(
        { error: "Query is required" },
        { status: 400, headers: corsHeaders }
      );
    }

    const result = await searchBusinesses(query, { location, limit });

    return NextResponse.json(result, { headers: corsHeaders });
  } catch (error) {
    console.error("[/api/search GET] Error:", error);
    return NextResponse.json(
      { error: error instanceof Error ? error.message : "Search failed" },
      { status: 500, headers: corsHeaders }
    );
  }
}

/**
 * POST /api/search
 * Proxy for Firecrawl Search — keeps API key server-side.
 * Called by the ElevenAgent webhook tool or directly from the frontend.
 */
export async function POST(req: NextRequest) {
  try {
    const body: SearchRequest = await req.json();

    if (!body.query) {
      return NextResponse.json(
        { error: "Query is required" },
        { status: 400, headers: corsHeaders }
      );
    }

    const result = await searchBusinesses(body.query, {
      location: body.location,
      limit: body.limit ?? 5,
    });

    return NextResponse.json(result, { headers: corsHeaders });
  } catch (error) {
    console.error("[/api/search POST] Error:", error);
    return NextResponse.json(
      {
        error: error instanceof Error ? error.message : "Search failed",
      },
      { status: 500, headers: corsHeaders }
    );
  }
}

/** Handle CORS preflight */
export async function OPTIONS() {
  return NextResponse.json({}, { headers: corsHeaders });
}
