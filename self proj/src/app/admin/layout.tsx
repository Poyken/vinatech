import React from "react";
import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/utils/supabase/server";
import { db } from "@/db/db";
import { users } from "@/db/schema";
import { eq } from "drizzle-orm";
import { 
  ShoppingBag, 
  Boxes, 
  LayoutDashboard, 
  ArrowLeft,
  ShieldAlert,
  ShieldCheck
} from "lucide-react";

export default async function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  // 1. Kiểm tra xác thực phía Server
  const supabase = await createClient();
  const { data: userData } = await supabase.auth.getUser();

  if (!userData?.user) {
    redirect("/login?redirect=/admin");
  }

  // 2. Truy vấn phân quyền người dùng (Role check) từ public.users
  const dbUsers = await db
    .select()
    .from(users)
    .where(eq(users.id, userData.user.id));
  
  const currentUser = dbUsers[0];

  // 3. Nếu không phải Admin, lập tức hiển thị trang cảnh báo 403
  if (!currentUser || currentUser.role !== "admin") {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center p-6 text-center">
        <div className="bg-white border border-zinc-200 rounded-3xl p-8 max-w-sm shadow-xl text-center">
          <div className="inline-flex items-center justify-center w-12 h-12 bg-red-50 text-red-600 rounded-full mb-4">
            <ShieldCheck className="w-6 h-6" />
          </div>
          <h1 className="text-lg font-bold text-zinc-900 mb-2">403 - Từ chối truy cập</h1>
          <p className="text-zinc-500 text-xs leading-relaxed mb-6">
            Tài khoản của bạn ({userData.user.email}) không có quyền quản trị để truy cập trang này.
          </p>
          <div className="space-y-3">
            <Link
              href="/"
              className="w-full py-2.5 px-4 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold rounded-xl text-xs transition-colors flex items-center justify-center gap-1.5"
            >
              <ArrowLeft className="w-4 h-4" />
              <span>Quay lại trang chủ</span>
            </Link>
          </div>
        </div>
      </div>
    );
  }

  // 4. Nếu là Admin, cho phép render giao diện Dashboard
  return (
    <div className="min-h-screen bg-slate-50 text-zinc-850 font-sans flex flex-col md:flex-row">
      {/* Sidebar */}
      <aside className="w-full md:w-64 bg-white border-b md:border-b-0 md:border-r border-zinc-200 p-6 flex flex-col justify-between">
        <div>
          {/* Brand Logo */}
          <Link href="/admin" className="flex items-center gap-2 mb-8 group">
            <div className="w-9 h-9 bg-linear-to-tr from-indigo-550 to-violet-550 rounded-xl flex items-center justify-center shadow-lg shadow-indigo-500/10 group-hover:scale-105 transition-transform duration-300">
              <ShieldAlert className="w-5 h-5 text-white" />
            </div>
            <span className="font-bold text-base bg-clip-text text-transparent bg-linear-to-r from-zinc-850 to-zinc-950 tracking-tight">
              Admin Portal
            </span>
          </Link>

          {/* Nav Menu */}
          <nav className="space-y-1">
            <Link
              href="/admin"
              className="flex items-center gap-3 px-4 py-2.5 rounded-xl text-sm font-semibold text-zinc-650 hover:bg-slate-50 hover:text-zinc-900 transition-colors"
            >
              <LayoutDashboard className="w-4.5 h-4.5" />
              <span>Đơn hàng</span>
            </Link>
            <Link
              href="/admin/products"
              className="flex items-center gap-3 px-4 py-2.5 rounded-xl text-sm font-semibold text-zinc-650 hover:bg-slate-50 hover:text-zinc-900 transition-colors"
            >
              <Boxes className="w-4.5 h-4.5" />
              <span>Sản phẩm</span>
            </Link>
          </nav>
        </div>

        {/* Quay lại trang chủ */}
        <div className="mt-8 pt-6 border-t border-zinc-150">
          <Link
            href="/"
            className="flex items-center gap-2 text-xs font-semibold text-zinc-500 hover:text-zinc-800 transition-colors"
          >
            <ArrowLeft className="w-4 h-4" />
            <span>Quay lại trang chủ</span>
          </Link>
        </div>
      </aside>

      {/* Main Content Area */}
      <main className="flex-1 p-6 md:p-10 overflow-y-auto">
        {children}
      </main>
    </div>
  );
}
