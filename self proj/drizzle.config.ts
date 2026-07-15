import { defineConfig } from "drizzle-kit";
import * as dotenv from "dotenv";

dotenv.config({ path: ".env.local" });

function getSafeDatabaseUrl(url?: string): string {
  if (!url) return "";
  try {
    new URL(url);
    return url;
  } catch {
    // Nếu URL không hợp lệ, có khả năng mật khẩu chứa ký tự đặc biệt chưa được encode.
    // Thực hiện trích xuất và encode phần mật khẩu.
    const match = url.match(/^(postgres(?:ql)?:\/\/)([^:]+):(.*)@([^/]+)\/(.+)$/);
    if (match) {
      const [_, protocol, username, password, hostAndPort, dbName] = match;
      const encodedPassword = encodeURIComponent(password);
      return `${protocol}${username}:${encodedPassword}@${hostAndPort}/${dbName}`;
    }
    return url;
  }
}

export default defineConfig({
  dialect: "postgresql",
  schema: "./src/db/schema.ts",
  out: "./src/db/migrations",
  dbCredentials: {
    url: getSafeDatabaseUrl(process.env.DATABASE_URL),
  },
});
