import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import * as schema from "./schema";

const connectionString =
  process.env.DATABASE_URL ||
  "postgres://postgres:postgres_local_pw@localhost:5432/vinatech_ecommerce";

function getSafeDatabaseUrl(url: string): string {
  try {
    new URL(url);
    return url;
  } catch {
    // Trích xuất và encode phần mật khẩu chứa ký tự đặc biệt
    const match = url.match(/^(postgres(?:ql)?:\/\/)([^:]+):(.*)@([^/]+)\/(.+)$/);
    if (match) {
      const [_, protocol, username, password, hostAndPort, dbName] = match;
      const encodedPassword = encodeURIComponent(password);
      return `${protocol}${username}:${encodedPassword}@${hostAndPort}/${dbName}`;
    }
    return url;
  }
}

// Bắt buộc cấu hình prepare: false để tương thích với Supabase Connection Pooler
const client = postgres(getSafeDatabaseUrl(connectionString), { prepare: false });

export const db = drizzle(client, { schema });
export type DbClient = typeof db;
export * from "./schema";
