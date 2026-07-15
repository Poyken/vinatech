"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import { useCartStore } from "@/store/useCartStore";
import { createClient } from "@/utils/supabase/client";
import { 
  ShoppingBag, 
  Search, 
  SlidersHorizontal, 
  User, 
  LogOut, 
  Plus, 
  Check, 
  Star,
  ChevronRight,
  TrendingUp
} from "lucide-react";
import { signOut } from "@/app/auth/actions";

interface Product {
  id: string;
  name: string;
  slug: string;
  description: string;
  price: string;
  stock: number;
}

export default function HomePage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [user, setUser] = useState<any>(null);
  const [addedItem, setAddedItem] = useState<string | null>(null);

  const cart = useCartStore();
  const supabase = createClient();

  useEffect(() => {
    // Check Auth Status
    supabase.auth.getUser().then(({ data }) => {
      if (data?.user) {
        setUser(data.user);
      }
    });

    // Fetch Products
    fetchProducts();
  }, []);

  const fetchProducts = async (queryStr = "") => {
    setLoading(true);
    try {
      const res = await fetch(`/api/products?${queryStr}`);
      const json = await res.json();
      if (json.success) {
        setProducts(json.data);
      }
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    fetchProducts(`query=${encodeURIComponent(search)}`);
  };

  const handleAddToCart = (product: Product) => {
    cart.addItem({
      id: product.id,
      name: product.name,
      price: parseFloat(product.price),
      slug: product.slug,
    });
    setAddedItem(product.id);
    setTimeout(() => setAddedItem(null), 1000);
  };

  return (
    <div className="min-h-screen bg-slate-50 text-zinc-800 font-sans selection:bg-indigo-500 selection:text-white">
      {/* 1. Header */}
      <header className="sticky top-0 z-50 bg-white/80 backdrop-blur-xl border-b border-zinc-200/80 px-6 py-4 flex items-center justify-between">
        <Link href="/" className="flex items-center gap-2 group">
          <div className="w-9 h-9 bg-linear-to-tr from-indigo-550 to-violet-550 rounded-xl flex items-center justify-center shadow-lg shadow-indigo-500/10 group-hover:scale-105 transition-transform duration-300">
            <ShoppingBag className="w-5 h-5 text-white" />
          </div>
          <span className="font-bold text-lg bg-clip-text text-transparent bg-linear-to-r from-zinc-850 to-zinc-950 tracking-tight">
            Vinatech Shop
          </span>
        </Link>

        {/* Search Bar */}
        <form onSubmit={handleSearchSubmit} className="hidden md:flex items-center max-w-md w-full mx-8 relative">
          <Search className="absolute left-3 w-4 h-4 text-zinc-400" />
          <input
            type="text"
            placeholder="Tìm kiếm sản phẩm công nghệ..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2 bg-zinc-100 border border-zinc-200 rounded-full text-sm text-zinc-800 placeholder-zinc-450 focus:outline-hidden focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/5 transition-all duration-300"
          />
        </form>

        {/* Actions */}
        <div className="flex items-center gap-4">
          <Link href="/cart" className="relative p-2 hover:bg-zinc-100 rounded-xl transition-colors group">
            <ShoppingBag className="w-6 h-6 text-zinc-550 group-hover:text-zinc-800 transition-colors" />
            {cart.getTotalItems() > 0 && (
              <span className="absolute -top-1 -right-1 w-5 h-5 bg-indigo-650 text-white text-[10px] font-bold rounded-full flex items-center justify-center animate-bounce">
                {cart.getTotalItems()}
              </span>
            )}
          </Link>

          {user ? (
            <div className="flex items-center gap-3 pl-2 border-l border-zinc-200">
              <div className="w-8 h-8 rounded-full bg-zinc-105 flex items-center justify-center text-xs font-semibold text-zinc-650">
                <User className="w-4 h-4" />
              </div>
              <span className="text-xs text-zinc-500 hidden lg:inline-block max-w-[120px] truncate">
                {user.email}
              </span>
              <button
                onClick={() => signOut()}
                className="p-2 hover:bg-red-500/5 text-zinc-500 hover:text-red-655 rounded-xl transition-colors cursor-pointer"
                title="Đăng xuất"
              >
                <LogOut className="w-4 h-4" />
              </button>
            </div>
          ) : (
            <Link
              href="/login"
              className="py-2 px-4 bg-white hover:bg-zinc-50 border border-zinc-200 text-sm font-medium rounded-xl transition-colors text-zinc-700"
            >
              Đăng nhập
            </Link>
          )}
        </div>
      </header>

      {/* 2. Hero Section */}
      <section className="relative px-6 py-16 md:py-24 max-w-7xl mx-auto overflow-hidden">
        <div className="absolute top-0 right-0 w-96 h-96 bg-indigo-500/5 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute bottom-0 left-0 w-96 h-96 bg-violet-500/5 rounded-full blur-3xl animate-pulse delay-75"></div>

        <div className="max-w-2xl z-10 relative">
          <div className="inline-flex items-center gap-2 px-3 py-1 bg-indigo-500/10 border border-indigo-500/20 rounded-full text-xs text-indigo-650 font-semibold mb-6">
            <TrendingUp className="w-3.5 h-3.5" />
            <span>Sản phẩm công nghệ mới nhất 2026</span>
          </div>
          <h1 className="text-4xl md:text-6xl font-extrabold tracking-tight leading-tight text-zinc-900">
            Khám phá kỷ nguyên <br />
            <span className="bg-clip-text text-transparent bg-linear-to-r from-indigo-600 via-purple-650 to-pink-600">
              Công nghệ Đỉnh cao
            </span>
          </h1>
          <p className="mt-6 text-zinc-500 text-sm md:text-base leading-relaxed">
            Nền tảng mua sắm thiết bị điện tử, linh kiện thông minh chất lượng cao, tối ưu hóa giao dịch an toàn và trải nghiệm người dùng liền mạch.
          </p>
          <div className="mt-10 flex flex-wrap gap-4">
            <a
              href="#products"
              className="py-3 px-6 bg-linear-to-r from-indigo-550 to-violet-550 hover:from-indigo-600 hover:to-violet-600 text-white font-semibold rounded-2xl text-sm flex items-center gap-2 shadow-lg shadow-indigo-500/15 transition-all duration-300 hover:scale-102 active:scale-98"
            >
              <span>Mua sắm ngay</span>
              <ChevronRight className="w-4 h-4" />
            </a>
          </div>
        </div>
      </section>

      {/* 3. Main Catalog Section */}
      <main id="products" className="max-w-7xl mx-auto px-6 py-12 border-t border-zinc-200">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-10">
          <div>
            <h2 className="text-2xl font-bold tracking-tight text-zinc-900">Danh sách sản phẩm</h2>
            <p className="text-zinc-500 text-xs mt-1">Được tuyển chọn kỹ lưỡng cho bạn</p>
          </div>
          <div className="flex items-center gap-3">
            <button className="flex items-center gap-2 px-4 py-2 bg-white border border-zinc-200 rounded-xl text-xs text-zinc-500 hover:text-zinc-800 hover:border-zinc-350 transition-colors">
              <SlidersHorizontal className="w-3.5 h-3.5" />
              <span>Bộ lọc</span>
            </button>
          </div>
        </div>

        {/* Loading Spinner */}
        {loading ? (
          <div className="flex flex-col items-center justify-center py-24">
            <span className="w-10 h-10 border-4 border-indigo-500/10 border-t-indigo-500 rounded-full animate-spin"></span>
            <span className="text-zinc-400 text-xs mt-4">Đang tải sản phẩm...</span>
          </div>
        ) : products.length === 0 ? (
          <div className="text-center py-24 bg-zinc-100 border border-dashed border-zinc-200 rounded-3xl">
            <p className="text-zinc-500 text-sm">Không tìm thấy sản phẩm nào phù hợp.</p>
          </div>
        ) : (
          /* Products Grid */
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {products.map((product) => (
              <div
                key={product.id}
                className="bg-white border border-zinc-200/80 hover:border-zinc-300 hover:shadow-lg rounded-3xl p-5 transition-all duration-300 hover:translate-y-[-4px] flex flex-col justify-between group relative"
              >
                {/* Product Image Placeholder */}
                <div className="aspect-video w-full rounded-2xl bg-slate-50 flex items-center justify-center mb-5 overflow-hidden relative border border-zinc-100">
                  <div className="absolute inset-0 bg-linear-to-br from-indigo-500/5 to-violet-500/2 group-hover:scale-105 transition-transform duration-500"></div>
                  <ShoppingBag className="w-8 h-8 text-zinc-300 group-hover:text-indigo-400/50 transition-colors duration-300" />
                </div>

                {/* Info */}
                <div>
                  <h3 className="font-bold text-sm text-zinc-850 group-hover:text-zinc-950 transition-colors truncate">
                    {product.name}
                  </h3>
                  <p className="text-zinc-500 text-xs mt-1.5 line-clamp-2 h-8 leading-relaxed">
                    {product.description || "Không có mô tả cho sản phẩm này."}
                  </p>
                  
                  {/* Rating placeholder */}
                  <div className="flex items-center gap-1 mt-3">
                    {[...Array(5)].map((_, i) => (
                      <Star key={i} className={`w-3 h-3 ${i < 4 ? "text-amber-500 fill-amber-500" : "text-zinc-250"}`} />
                    ))}
                    <span className="text-[10px] text-zinc-400 ml-1.5">(4.0)</span>
                  </div>
                </div>

                {/* Footer card */}
                <div className="flex items-center justify-between mt-6 pt-4 border-t border-zinc-100">
                  <div className="flex flex-col">
                    <span className="text-[10px] text-zinc-400 font-semibold uppercase tracking-wider">Giá bán</span>
                    <span className="text-base font-bold text-zinc-900 mt-0.5">
                      {parseFloat(product.price).toLocaleString("vi-VN")} <span className="text-xs text-indigo-600 font-normal">đ</span>
                    </span>
                  </div>

                  <button
                    onClick={() => handleAddToCart(product)}
                    className="w-10 h-10 bg-slate-50 hover:bg-indigo-650 text-zinc-550 hover:text-white border border-zinc-150 rounded-xl flex items-center justify-center transition-all duration-300 cursor-pointer active:scale-90"
                    title="Thêm vào giỏ hàng"
                  >
                    {addedItem === product.id ? (
                      <Check className="w-5 h-5 text-indigo-600 group-hover:text-white" />
                    ) : (
                      <Plus className="w-5 h-5" />
                    )}
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>

      {/* 4. Footer */}
      <footer className="bg-zinc-100 border-t border-zinc-200 py-12 px-6 mt-24 text-center text-zinc-500 text-xs">
        <p>© 2026 Vinatech Shop. All rights reserved.</p>
        <p className="mt-2">Được thiết kế tối ưu hiệu năng chạy Serverless & bảo mật cao.</p>
      </footer>
    </div>
  );
}
