import NextAuth from "next-auth";
import CredentialsProvider from "next-auth/providers/credentials";

const handler = NextAuth({
  providers: [
    CredentialsProvider({
      name: "Credentials",
      credentials: {
        username: { label: "Tên đăng nhập", type: "text" },
        password: { label: "Mật khẩu", type: "password" }
      },
      async authorize(credentials) {
        // Admin credentials: admin / admin123
        if (credentials?.username === "admin" && credentials?.password === "admin123") {
          return { id: "admin-id", name: "Poyken Admin", email: "admin@poykensound.vn" };
        }
        return null;
      }
    })
  ],
  pages: {
    signIn: "/admin/login",
  },
  secret: process.env.NEXTAUTH_SECRET || "poyken-sound-jwt-secret-placeholder-2026",
  session: {
    strategy: "jwt",
  }
});

export async function GET(req: Request, context: { params: Promise<{ nextauth: string[] }> }) {
  const params = await context.params;
  return handler(req, { params });
}

export async function POST(req: Request, context: { params: Promise<{ nextauth: string[] }> }) {
  const params = await context.params;
  return handler(req, { params });
}
