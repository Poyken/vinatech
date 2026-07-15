import { type NextRequest } from "next/server";
import { updateSession } from "./utils/supabase/middleware";

export async function proxy(request: NextRequest) {
  return await updateSession(request);
}

export const config = {
  matcher: [
    /*
     * So khớp tất cả các đường dẫn ngoại trừ các tài nguyên tĩnh:
     * - _next/static (tĩnh)
     * - _next/image (tối ưu hóa ảnh)
     * - favicon.ico (icon)
     * - Các file ảnh tĩnh khác (svg, png, jpg, jpeg, gif, webp)
     */
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
