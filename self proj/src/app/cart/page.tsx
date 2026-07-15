"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import { useCartStore } from "@/store/useCartStore";
import { createClient } from "@/utils/supabase/client";
import { 
  ShoppingBag, 
  Trash2, 
  Plus, 
  Minus, 
  MapPin, 
  CreditCard,
  ArrowLeft,
  ChevronRight,
  ShieldCheck
} from "lucide-react";
import { useRouter } from "next/navigation";

export default function CartPage() {
  const cart = useCartStore();
  const router = useRouter();
  const supabase = createClient();

  const [user, setUser] = useState<any>(null);
  const [shippingAddress, setShippingAddress] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => {
      if (data?.user) {
        setUser(data.user);
      }
    });
  }, []);

  const handleCheckout = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) {
      router.push("/login?redirect=/cart");
      return;
    }

    if (!shippingAddress.trim()) {
      setError("Vui lòng nhập địa chỉ nhận hàng.");
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const response = await fetch("/api/checkout", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          items: cart.items.map(item => ({
            productId: item.id,
            quantity: item.quantity,
          })),
          shippingAddress,
          paymentMethod: "vnpay",
        }),
      });

      const data = await response.json();

      if (data.success && data.paymentUrl) {
        // Clear cart locally
        cart.clearCart();
        // Redirect to VNPAY Sandbox
        window.location.href = data.paymentUrl;
      } else {
        setError(data.error || "Có lỗi xảy ra khi tạo đơn hàng.");
      }
    } catch (err) {
      console.error(err);
      setError("Lỗi mạng, vui lòng thử lại sau.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 text-zinc-850 font-sans">
      {/* Header */}
      <header className="bg-white/85 backdrop-blur-xl border-b border-zinc-200/80 px-6 py-4 flex items-center justify-between">
        <Link href="/" className="flex items-center gap-2 group">
          <div className="w-9 h-9 bg-linear-to-tr from-indigo-550 to-violet-550 rounded-xl flex items-center justify-center shadow-lg shadow-indigo-500/10 group-hover:scale-105 transition-transform duration-300">
            <ShoppingBag className="w-5 h-5 text-white" />
          </div>
          <span className="font-bold text-lg bg-clip-text text-transparent bg-linear-to-r from-zinc-850 to-zinc-950 tracking-tight">
            Vinatech Shop
          </span>
        </Link>
        <Link href="/" className="text-xs text-zinc-500 hover:text-zinc-850 flex items-center gap-1 transition-colors">
          <ArrowLeft className="w-3.5 h-3.5" />
          <span>Quay lại trang chủ</span>
        </Link>
      </header>

      {/* Main Cart Content */}
      <main className="max-w-6xl mx-auto px-6 py-12">
        <h1 className="text-3xl font-extrabold tracking-tight text-zinc-900 mb-8">Giỏ hàng của bạn</h1>

        {cart.items.length === 0 ? (
          <div className="text-center py-20 bg-white border border-zinc-200 rounded-3xl flex flex-col items-center justify-center shadow-xs">
            <div className="w-16 h-16 bg-slate-50 rounded-2xl flex items-center justify-center mb-4 text-zinc-400 border border-zinc-150">
              <ShoppingBag className="w-8 h-8" />
            </div>
            <p className="text-zinc-500 text-sm mb-6">Giỏ hàng của bạn đang trống.</p>
            <Link
              href="/"
              className="py-2.5 px-6 bg-indigo-600 hover:bg-indigo-700 text-white text-xs font-semibold rounded-xl transition-colors"
            >
              Tiếp tục mua sắm
            </Link>
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            {/* Cart Items List */}
            <div className="lg:col-span-2 space-y-4">
              {cart.items.map((item) => (
                <div
                  key={item.id}
                  className="bg-white border border-zinc-200/80 shadow-xs rounded-3xl p-5 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4"
                >
                  <div className="flex items-center gap-4">
                    <div className="w-14 h-14 bg-slate-50 rounded-xl flex items-center justify-center text-zinc-450 border border-zinc-100">
                      <ShoppingBag className="w-6 h-6" />
                    </div>
                    <div>
                      <h3 className="font-bold text-sm text-zinc-800">{item.name}</h3>
                      <p className="text-xs text-zinc-500 mt-1">
                        Giá: {item.price.toLocaleString("vi-VN")} đ
                      </p>
                    </div>
                  </div>

                  <div className="flex items-center justify-between w-full sm:w-auto gap-6 border-t sm:border-t-0 border-zinc-100 pt-4 sm:pt-0">
                    {/* Quantity Selector */}
                    <div className="flex items-center bg-slate-50 border border-zinc-200 rounded-xl px-2 py-1">
                      <button
                        onClick={() => cart.updateQuantity(item.id, item.quantity - 1)}
                        className="p-1 hover:text-zinc-800 text-zinc-400 transition-colors cursor-pointer"
                      >
                        <Minus className="w-3.5 h-3.5" />
                      </button>
                      <span className="px-3 text-xs font-semibold w-8 text-center text-zinc-700">
                        {item.quantity}
                      </span>
                      <button
                        onClick={() => cart.updateQuantity(item.id, item.quantity + 1)}
                        className="p-1 hover:text-zinc-800 text-zinc-400 transition-colors cursor-pointer"
                      >
                        <Plus className="w-3.5 h-3.5" />
                      </button>
                    </div>

                    {/* Subtotal & Delete */}
                    <div className="flex items-center gap-4">
                      <span className="font-bold text-sm text-zinc-900 min-w-[90px] text-right">
                        {(item.price * item.quantity).toLocaleString("vi-VN")} đ
                      </span>
                      <button
                        onClick={() => cart.removeItem(item.id)}
                        className="p-2 hover:bg-red-500/5 text-zinc-400 hover:text-red-600 rounded-xl transition-colors cursor-pointer"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>

            {/* Order Summary & Shipping Form */}
            <div className="space-y-6">
              <div className="bg-white border border-zinc-200/80 rounded-3xl p-6 shadow-xl shadow-zinc-200/40">
                <h2 className="text-lg font-bold text-zinc-900 mb-6">Tóm tắt đơn hàng</h2>

                <div className="space-y-3 text-xs text-zinc-500">
                  <div className="flex justify-between">
                    <span>Tạm tính</span>
                    <span className="text-zinc-850">{cart.getTotalPrice().toLocaleString("vi-VN")} đ</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Phí vận chuyển</span>
                    <span className="text-green-600 font-medium">Miễn phí</span>
                  </div>
                  <div className="border-t border-zinc-150 pt-4 flex justify-between text-sm font-bold text-zinc-900">
                    <span>Tổng tiền</span>
                    <span className="text-indigo-600">{cart.getTotalPrice().toLocaleString("vi-VN")} đ</span>
                  </div>
                </div>

                <form onSubmit={handleCheckout} className="mt-8 space-y-5">
                  {error && (
                    <div className="bg-red-500/5 border border-red-500/10 text-red-600 text-xs rounded-xl p-3">
                      {error}
                    </div>
                  )}

                  {/* Shipping Address */}
                  <div className="space-y-2">
                    <label className="text-[10px] font-bold text-zinc-500 uppercase tracking-wider block">
                      Địa chỉ nhận hàng
                    </label>
                    <div className="relative">
                      <span className="absolute top-3 left-3 text-zinc-400">
                        <MapPin className="w-4 h-4" />
                      </span>
                      <textarea
                        placeholder="Số nhà, Tên đường, Quận/Huyện, Tỉnh/Thành phố"
                        value={shippingAddress}
                        onChange={(e) => setShippingAddress(e.target.value)}
                        required
                        rows={2}
                        className="w-full pl-10 pr-4 py-2.5 bg-white border border-zinc-200 rounded-2xl text-xs text-zinc-800 placeholder-zinc-400 focus:outline-hidden focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/5 transition-all"
                      />
                    </div>
                  </div>

                  {/* Payment Method */}
                  <div className="space-y-2">
                    <label className="text-[10px] font-bold text-zinc-500 uppercase tracking-wider block">
                      Phương thức thanh toán
                    </label>
                    <div className="flex items-center gap-3 p-3.5 bg-slate-50 border border-indigo-500/30 rounded-2xl text-xs">
                      <CreditCard className="w-4 h-4 text-indigo-650" />
                      <div className="flex-1 font-semibold text-zinc-700">Thanh toán qua VNPAY</div>
                      <ShieldCheck className="w-4 h-4 text-indigo-650" />
                    </div>
                  </div>

                  {/* Submit Button */}
                  <button
                    type="submit"
                    disabled={loading}
                    className="w-full py-3 bg-linear-to-r from-indigo-550 to-violet-550 text-white text-xs font-semibold rounded-2xl shadow-lg shadow-indigo-500/15 hover:from-indigo-600 hover:to-violet-600 transition-all flex items-center justify-center gap-2 group disabled:opacity-50 disabled:pointer-events-none cursor-pointer"
                  >
                    {loading ? (
                      <span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></span>
                    ) : (
                      <>
                        <span>{user ? "Tiến hành thanh toán" : "Đăng nhập để đặt hàng"}</span>
                        <ChevronRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                      </>
                    )}
                  </button>
                </form>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
