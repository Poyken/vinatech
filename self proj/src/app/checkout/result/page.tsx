"use client";

import React, { useEffect, useState, Suspense } from "react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { 
  CheckCircle2, 
  XCircle, 
  ShoppingBag, 
  ArrowLeft, 
  FileText
} from "lucide-react";

function CheckoutResultContent() {
  const searchParams = useSearchParams();
  const success = searchParams.get("success") === "true";
  const orderId = searchParams.get("orderId");
  const error = searchParams.get("error");
  const code = searchParams.get("code");

  return (
    <div className="min-h-screen bg-radial from-slate-100 via-zinc-50 to-slate-200 flex items-center justify-center px-4 relative overflow-hidden">
      {/* Vòng tròn ánh sáng */}
      <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-indigo-500/5 rounded-full blur-3xl animate-pulse"></div>
      <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-violet-500/5 rounded-full blur-3xl animate-pulse delay-75"></div>

      <div className="w-full max-w-md z-10">
        <div className="bg-white/70 backdrop-blur-xl border border-zinc-200/80 rounded-3xl p-8 shadow-2xl shadow-zinc-200/40 text-center">
          {success ? (
            /* Success State */
            <div className="space-y-6">
              <div className="inline-flex items-center justify-center w-16 h-16 bg-green-500/10 text-green-600 rounded-full animate-bounce">
                <CheckCircle2 className="w-10 h-10" />
              </div>
              
              <div className="space-y-2">
                <h1 className="text-2xl font-bold text-zinc-900 tracking-tight">Thanh toán thành công!</h1>
                <p className="text-sm text-zinc-500">Cảm ơn bạn đã mua sắm tại Vinatech Shop.</p>
              </div>

              {orderId && (
                <div className="bg-slate-50 border border-zinc-200/80 rounded-2xl p-4 text-left space-y-2.5">
                  <div className="flex justify-between text-xs">
                    <span className="text-zinc-400">Mã đơn hàng:</span>
                    <span className="font-mono text-zinc-700 font-semibold">{orderId}</span>
                  </div>
                  <div className="flex justify-between text-xs">
                    <span className="text-zinc-400">Trạng thái:</span>
                    <span className="text-green-600 font-medium">Đã thanh toán</span>
                  </div>
                  <div className="flex justify-between text-xs">
                    <span className="text-zinc-400">Vận chuyển:</span>
                    <span className="text-zinc-700">Đang chuẩn bị hàng</span>
                  </div>
                </div>
              )}

              <div className="pt-4 space-y-3">
                <Link
                  href="/"
                  className="w-full py-3 px-4 bg-linear-to-r from-indigo-550 to-violet-550 hover:from-indigo-600 hover:to-violet-600 text-white font-semibold rounded-2xl text-xs shadow-lg shadow-indigo-500/15 flex items-center justify-center gap-2 transition-all active:scale-98"
                >
                  <ShoppingBag className="w-4 h-4" />
                  <span>Tiếp tục mua sắm</span>
                </Link>
                
                <button
                  onClick={() => window.print()}
                  className="w-full py-3 px-4 bg-white hover:bg-zinc-50 border border-zinc-200 text-zinc-650 hover:text-zinc-850 font-semibold rounded-2xl text-xs flex items-center justify-center gap-2 transition-colors cursor-pointer"
                >
                  <FileText className="w-4 h-4" />
                  <span>In hóa đơn mua hàng</span>
                </button>
              </div>
            </div>
          ) : (
            /* Failure State */
            <div className="space-y-6">
              <div className="inline-flex items-center justify-center w-16 h-16 bg-red-500/10 text-red-600 rounded-full animate-pulse">
                <XCircle className="w-10 h-10" />
              </div>

              <div className="space-y-2">
                <h1 className="text-2xl font-bold text-zinc-900 tracking-tight">Thanh toán thất bại</h1>
                <p className="text-sm text-zinc-500">
                  {error === "invalid_signature" 
                    ? "Lỗi xác thực chữ ký số giao dịch."
                    : "Giao dịch đã bị hủy hoặc không thành công."}
                </p>
              </div>

              {orderId && (
                <div className="bg-slate-50 border border-zinc-200/80 rounded-2xl p-4 text-left space-y-2.5">
                  <div className="flex justify-between text-xs">
                    <span className="text-zinc-400">Mã đơn hàng:</span>
                    <span className="font-mono text-zinc-700 font-semibold">{orderId}</span>
                  </div>
                  {code && (
                    <div className="flex justify-between text-xs">
                      <span className="text-zinc-400">Mã lỗi VNPAY:</span>
                      <span className="text-red-500 font-mono font-medium">{code}</span>
                    </div>
                  )}
                </div>
              )}

              <div className="pt-4 space-y-3">
                <Link
                  href="/cart"
                  className="w-full py-3 px-4 bg-linear-to-r from-indigo-550 to-violet-550 hover:from-indigo-600 hover:to-violet-600 text-white font-semibold rounded-2xl text-xs shadow-lg shadow-indigo-500/15 flex items-center justify-center gap-2 transition-all active:scale-98"
                >
                  <ArrowLeft className="w-4 h-4" />
                  <span>Quay lại giỏ hàng</span>
                </Link>
                
                <Link
                  href="/"
                  className="w-full py-3 px-4 bg-white hover:bg-zinc-50 border border-zinc-200 text-zinc-650 hover:text-zinc-850 font-semibold rounded-2xl text-xs flex items-center justify-center gap-2 transition-colors"
                >
                  <ShoppingBag className="w-4 h-4" />
                  <span>Quay về trang chủ</span>
                </Link>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default function CheckoutResultPage() {
  return (
    <Suspense
      fallback={
        <div className="min-h-screen bg-slate-50 flex items-center justify-center text-zinc-800">
          <span className="w-10 h-10 border-4 border-indigo-500/10 border-t-indigo-500 rounded-full animate-spin"></span>
        </div>
      }
    >
      <CheckoutResultContent />
    </Suspense>
  );
}
