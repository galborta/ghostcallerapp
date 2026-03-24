import { Business, SearchResult } from "./types";

const FIRECRAWL_API_URL = "https://api.firecrawl.dev/v1/search";

interface FirecrawlSearchResponse {
  success: boolean;
  data: Array<{
    url: string;
    title: string;
    description: string;
    markdown?: string;
    metadata?: Record<string, unknown>;
  }>;
}

/**
 * Search for businesses using Firecrawl Search API.
 * Returns structured business data extracted from web results.
 */
export async function searchBusinesses(
  query: string,
  options?: { location?: string; limit?: number }
): Promise<SearchResult> {
  const apiKey = process.env.FIRECRAWL_API_KEY;
  if (!apiKey) throw new Error("FIRECRAWL_API_KEY not set");

  // Build enriched query for better business results
  const baseQuery = options?.location
    ? `${query} in ${options.location}`
    : query;
  const searchQuery = `${baseQuery} phone number address reviews`;

  const response = await fetch(FIRECRAWL_API_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      query: searchQuery,
      limit: options?.limit ?? 5,
      // No scrapeOptions — much faster response, avoids webhook timeout
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Firecrawl search failed: ${response.status} — ${error}`);
  }

  const data: FirecrawlSearchResponse = await response.json();

  // Extract business info from search results
  const businesses: Business[] = data.data.map((result) => {
    const extracted = extractBusinessInfo(
      result.title,
      result.description,
      result.markdown ?? "",
      result.url
    );
    return extracted;
  });

  return {
    businesses: businesses.filter((b) => b.name), // filter empty results
    query: searchQuery,
    timestamp: Date.now(),
  };
}

/**
 * Extract structured business data from raw search result content.
 * Uses heuristics to pull phone numbers, ratings, addresses, etc.
 */
function extractBusinessInfo(
  title: string,
  description: string,
  markdown: string,
  sourceUrl: string
): Business {
  const fullText = `${title}\n${description}\n${markdown}`;

  // Extract phone number (US + international formats)
  const phoneMatch = fullText.match(
    /(\+?\d{1,3}[-.\s]?\(?\d{1,4}\)?[-.\s]?\d{2,4}[-.\s]?\d{2,4}[-.\s]?\d{0,4})/
  );

  // Extract rating (e.g., "4.5 stars", "4.8/5", "★ 4.5")
  const ratingMatch = fullText.match(
    /(\d+\.?\d?)\s*(?:\/\s*5|stars?|★|⭐|rating)/i
  );

  // Extract review count (e.g., "(123 reviews)", "1,234 reviews")
  const reviewMatch = fullText.match(
    /(\d[,\d]*)\s*(?:reviews?|ratings?|opiniones)/i
  );

  // Extract address (basic heuristic — look for street patterns)
  const addressMatch = fullText.match(
    /(\d+\s+[\w\s]+(?:St|Ave|Blvd|Dr|Rd|Ln|Way|Ct|Pl|Pkwy|Hwy)[.,]?\s*[\w\s]*,?\s*[A-Z]{2}\s*\d{5}?)/i
  );

  // Extract price range
  const priceMatch = fullText.match(/(\$+)(?:\s|$)/);

  // Clean title (remove " - Yelp", " | Google", etc.)
  const cleanName = title
    .replace(/\s*[-–|].*(?:yelp|google|tripadvisor|maps|menu).*/i, "")
    .trim();

  return {
    name: cleanName,
    phone: phoneMatch ? phoneMatch[1].trim() : null,
    address: addressMatch ? addressMatch[1].trim() : null,
    rating: ratingMatch ? parseFloat(ratingMatch[1]) : null,
    reviewCount: reviewMatch
      ? parseInt(reviewMatch[1].replace(",", ""))
      : null,
    hours: null, // Would need more specific scraping
    cuisine: null, // Could be extracted from categories
    priceRange: priceMatch ? priceMatch[1] : null,
    website: sourceUrl,
    snippet: description.slice(0, 200),
    sourceUrl,
  };
}
