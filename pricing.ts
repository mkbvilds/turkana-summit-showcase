// Shared pricing — imported by mpesa-pay and paystack-pay.
// Keep this in sync with the priceMapping object in dashboard.html if you
// change package prices, since that copy is only used for on-screen display.

export const PRICE_MAP_KES: Record<string, number> = {
  "Standard Participant Pass — Ksh 1,500": 1500,
  "Cooperative Mining Package — Ksh 5,000 (up to 4 pax)": 5000,
  "Gold Sponsor — USD 40,000": 40000 * 130,
  "Silver Sponsor — USD 25,000": 25000 * 130,
  "Copper Sponsor — USD 10,000": 10000 * 130,
  "Bronze Sponsor — USD 5,000": 5000 * 130,
  "Tier 1 Exhibitor — KES 50,000": 50000,
  "Standard Exhibitor — KES 30,000": 30000,
  "International Exhibitor — USD 750": 750 * 130,
};

export const ADDON_PRICES_KES = {
  gala: 2500,
  tour: 5000,
  extraRep: 1500,
};

export function getBasePriceKES(pkg?: string | null): number {
  if (!pkg) return 1500;
  return PRICE_MAP_KES[pkg] ?? 1500;
}

export interface AddonSelection {
  gala?: boolean;
  tour?: boolean;
  galaTickets?: number;
  tourTickets?: number;
  extraReps?: number;
}

// Total price in KES for a package + chosen add-ons.
export function computeTotalKES(pkg: string | null | undefined, addons: AddonSelection | undefined): number {
  const base = getBasePriceKES(pkg);
  const galaCount = addons?.galaTickets ?? (addons?.gala ? 1 : 0);
  const tourCount = addons?.tourTickets ?? (addons?.tour ? 1 : 0);
  const gala = galaCount * ADDON_PRICES_KES.gala;
  const tour = tourCount * ADDON_PRICES_KES.tour;
  const reps = (addons?.extraReps || 0) * ADDON_PRICES_KES.extraRep;
  return Math.round(base + gala + tour + reps);
}

// Approximate FX rates from KES. Update these periodically, or better, wire
// this up to a live rates API before going live — hard-coded rates will
// drift out of date.
export const FX_RATES_FROM_KES: Record<string, number> = {
  KES: 1,
  USD: 1 / 130,
  EUR: 1 / 140,
};

export function convertFromKES(amountKES: number, currency: string): number {
  const rate = FX_RATES_FROM_KES[currency];
  if (!rate) throw new Error(`Unsupported currency: ${currency}`);
  return Math.round(amountKES * rate * 100) / 100; // 2dp
}