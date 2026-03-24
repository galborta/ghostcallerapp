"use client";

import { motion } from "framer-motion";
import { Business } from "@/lib/types";

interface BusinessCardProps {
  business: Business;
  index: number;
  isSelected?: boolean;
  onCallClick?: (business: Business) => void;
}

/** Render star rating as SVG (full, half, empty stars) */
function StarRating({ rating }: { rating: number }) {
  const stars = [];
  for (let i = 1; i <= 5; i++) {
    if (rating >= i) {
      // Full star
      stars.push(
        <svg key={i} width="14" height="14" viewBox="0 0 20 20" className="text-amber-400 fill-current">
          <path d="M10 1l2.39 4.84 5.34.78-3.87 3.77.91 5.33L10 13.28l-4.77 2.51.91-5.33L2.27 6.62l5.34-.78L10 1z" />
        </svg>
      );
    } else if (rating >= i - 0.5) {
      // Half star
      stars.push(
        <svg key={i} width="14" height="14" viewBox="0 0 20 20" className="text-amber-400">
          <defs>
            <linearGradient id={`half-${i}`}>
              <stop offset="50%" stopColor="currentColor" />
              <stop offset="50%" stopColor="#d4d4d8" />
            </linearGradient>
          </defs>
          <path
            d="M10 1l2.39 4.84 5.34.78-3.87 3.77.91 5.33L10 13.28l-4.77 2.51.91-5.33L2.27 6.62l5.34-.78L10 1z"
            fill={`url(#half-${i})`}
          />
        </svg>
      );
    } else {
      // Empty star
      stars.push(
        <svg key={i} width="14" height="14" viewBox="0 0 20 20" className="text-zinc-300 fill-current">
          <path d="M10 1l2.39 4.84 5.34.78-3.87 3.77.91 5.33L10 13.28l-4.77 2.51.91-5.33L2.27 6.62l5.34-.78L10 1z" />
        </svg>
      );
    }
  }
  return <div className="flex items-center gap-0.5">{stars}</div>;
}

export default function BusinessCard({
  business,
  index,
  isSelected = false,
  onCallClick,
}: BusinessCardProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.1, duration: 0.3 }}
      className={`
        rounded-2xl border p-4 transition-all cursor-pointer
        ${
          isSelected
            ? "border-green-500 bg-green-50 shadow-lg shadow-green-100"
            : "border-zinc-200 bg-white hover:border-zinc-300 hover:shadow-md"
        }
      `}
    >
      <div className="flex items-start justify-between gap-3">
        <div className="flex-1 min-w-0">
          {/* Business name */}
          <h3 className="font-semibold text-zinc-900 truncate text-base">
            {business.name}
          </h3>

          {/* Rating + reviews row */}
          {business.rating && (
            <div className="flex items-center gap-1.5 mt-1">
              <span className="text-sm font-medium text-zinc-700">
                {business.rating}
              </span>
              <StarRating rating={business.rating} />
              {business.reviewCount && (
                <span className="text-sm text-zinc-400">
                  ({business.reviewCount.toLocaleString()})
                </span>
              )}
            </div>
          )}

          {/* Tags row: cuisine, price */}
          <div className="flex items-center gap-2 mt-1.5">
            {business.cuisine && (
              <span className="text-xs text-zinc-500 bg-zinc-100 px-2 py-0.5 rounded-full">
                {business.cuisine}
              </span>
            )}
            {business.priceRange && (
              <span className="text-xs text-zinc-500 bg-zinc-100 px-2 py-0.5 rounded-full">
                {business.priceRange}
              </span>
            )}
          </div>

          {/* Address */}
          {business.address && (
            <div className="flex items-center gap-1.5 mt-2 text-sm text-zinc-500">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="shrink-0 text-zinc-400">
                <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z" />
                <circle cx="12" cy="10" r="3" />
              </svg>
              <span className="truncate">{business.address}</span>
            </div>
          )}

          {/* Phone */}
          {business.phone && (
            <div className="flex items-center gap-1.5 mt-1 text-sm text-zinc-600">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="shrink-0 text-zinc-400">
                <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" />
              </svg>
              <span className="font-mono text-xs">{business.phone}</span>
            </div>
          )}

          {/* Snippet */}
          {business.snippet && (
            <p className="mt-2 text-xs text-zinc-400 line-clamp-2 leading-relaxed">
              {business.snippet}
            </p>
          )}
        </div>

        {/* Call button */}
        {business.phone && onCallClick && (
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            onClick={(e) => {
              e.stopPropagation();
              onCallClick(business);
            }}
            className={`
              shrink-0 flex items-center gap-1.5 px-4 py-2.5 rounded-xl text-sm font-medium transition-colors
              ${
                isSelected
                  ? "bg-green-500 text-white hover:bg-green-600"
                  : "bg-indigo-500 text-white hover:bg-indigo-600"
              }
            `}
          >
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" />
            </svg>
            {isSelected ? "Calling..." : "Call"}
          </motion.button>
        )}
      </div>
    </motion.div>
  );
}
