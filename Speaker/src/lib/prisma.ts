import { PrismaClient } from '../generated/prisma/client';

/**
 * Lazy Prisma Client singleton.
 * 
 * Prisma 7 requires an "adapter" or "accelerateUrl" at construction time.
 * If no PostgreSQL adapter is configured, we set prisma to null so
 * dataService.ts can gracefully fall back to in-memory mock data.
 */

const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient | null };

function createPrismaClient(): PrismaClient | null {
  try {
    // Attempt to dynamically import and configure the PG adapter
    // For now, if DATABASE_URL is not set, skip initialization entirely
    if (!process.env.DATABASE_URL) {
      console.warn('[Prisma] DATABASE_URL not set — using local fallback data.');
      return null;
    }

    // Dynamic adapter setup would go here for production deployments.
    // For local dev without a running DB, we return null.
    console.warn('[Prisma] Adapter not configured — using local fallback data.');
    return null;
  } catch (e) {
    console.warn('[Prisma] Failed to initialize PrismaClient:', e);
    return null;
  }
}

export const prisma: PrismaClient | null =
  globalForPrisma.prisma !== undefined
    ? globalForPrisma.prisma
    : createPrismaClient();

if (process.env.NODE_ENV !== 'production' && prisma) {
  globalForPrisma.prisma = prisma;
}
