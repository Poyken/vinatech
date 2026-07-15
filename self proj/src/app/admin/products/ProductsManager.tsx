"use client";

import React, { useState } from "react";
import { createProduct, deleteProduct } from "@/app/admin/actions";
import { 
  Plus, 
  Trash2, 
  Tag, 
  Database, 
  Image as ImageIcon,
  CheckCircle,
  XCircle,
  Upload
} from "lucide-react";

interface Product {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  price: string;
  stock: number;
  isActive: boolean;
}

export default function ProductsManager({ 
  initialProducts,
  categories 
}: { 
  initialProducts: any[];
  categories: any[];
}) {
  const [productsList, setProductsList] = useState<Product[]>(initialProducts);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Form State
  const [name, setName] = useState("");
  const [slug, setSlug] = useState("");
  const [price, setPrice] = useState("");
  const [stock, setStock] = useState(10);
  const [categoryId, setCategoryId] = useState("");
  const [description, setDescription] = useState("");
  const [uploadingImage, setUploadingImage] = useState(false);
  const [imageUrl, setImageUrl] = useState("");

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploadingImage(true);
    setError(null);

    const formData = new FormData();
    formData.append("file", file);

    try {
      const res = await fetch("/api/upload", {
        method: "POST",
        body: formData,
      });

      const data = await res.json();
      if (data.success) {
        setImageUrl(data.url);
      } else {
        setError(data.error || "Không thể upload ảnh.");
      }
    } catch (err) {
      setError("Lỗi kết nối khi upload.");
    } finally {
      setUploadingImage(false);
    }
  };

  const handleCreateProduct = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    const res = await createProduct({
      name,
      slug: slug || name.toLowerCase().replace(/[^a-z0-9]+/g, "-"),
      categoryId,
      description,
      price,
      stock,
    });

    setLoading(false);

    if (res.success) {
      // Reset form
      setName("");
      setSlug("");
      setPrice("");
      setStock(10);
      setCategoryId("");
      setDescription("");
      setImageUrl("");
      
      // Reload page or list (for simplicity, alert success and tell them to reload list)
      alert("Đã thêm sản phẩm thành công!");
      window.location.reload();
    } else {
      setError(res.error || "Không thể tạo sản phẩm.");
    }
  };

  const handleDelete = async (productId: string) => {
    if (!confirm("Bạn có chắc chắn muốn xóa sản phẩm này?")) return;

    const res = await deleteProduct(productId);
    if (res.success) {
      setProductsList((prev) => prev.filter((p) => p.id !== productId));
    } else {
      alert(res.error || "Không thể xóa sản phẩm.");
    }
  };

  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
      {/* 1. Form Thêm Sản Phẩm Mới */}
      <div className="bg-white border border-zinc-200/80 rounded-3xl p-6 shadow-xl shadow-zinc-200/30 h-fit">
        <h2 className="text-lg font-bold text-zinc-900 mb-6 flex items-center gap-2">
          <Plus className="w-5 h-5 text-indigo-650" />
          <span>Thêm sản phẩm mới</span>
        </h2>

        <form onSubmit={handleCreateProduct} className="space-y-4 text-xs">
          {error && (
            <div className="bg-red-500/5 border border-red-500/10 text-red-600 rounded-xl p-3">
              {error}
            </div>
          )}

          {/* Name */}
          <div className="space-y-1.5">
            <label className="font-bold text-zinc-500 uppercase tracking-wider block">Tên sản phẩm</label>
            <input
              type="text"
              placeholder="VD: MacBook Air M4"
              value={name}
              onChange={(e) => setName(e.target.value)}
              required
              className="w-full px-4 py-2.5 bg-white border border-zinc-200 rounded-xl text-zinc-800 focus:outline-hidden focus:border-indigo-500"
            />
          </div>

          {/* Slug */}
          <div className="space-y-1.5">
            <label className="font-bold text-zinc-500 uppercase tracking-wider block">Slug (Đường dẫn)</label>
            <input
              type="text"
              placeholder="VD: macbook-air-m4 (Để trống tự động tạo)"
              value={slug}
              onChange={(e) => setSlug(e.target.value)}
              className="w-full px-4 py-2.5 bg-white border border-zinc-200 rounded-xl text-zinc-850 focus:outline-hidden focus:border-indigo-500"
            />
          </div>

          {/* Category */}
          <div className="space-y-1.5">
            <label className="font-bold text-zinc-500 uppercase tracking-wider block">Danh mục</label>
            <select
              value={categoryId}
              onChange={(e) => setCategoryId(e.target.value)}
              className="w-full px-4 py-2.5 bg-white border border-zinc-200 rounded-xl text-zinc-850 focus:outline-hidden focus:border-indigo-500"
            >
              <option value="">Chọn danh mục...</option>
              {categories.map((cat) => (
                <option key={cat.id} value={cat.id}>
                  {cat.name}
                </option>
              ))}
            </select>
          </div>

          {/* Price & Stock */}
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <label className="font-bold text-zinc-500 uppercase tracking-wider block">Giá bán (đ)</label>
              <input
                type="number"
                placeholder="VD: 15000000"
                value={price}
                onChange={(e) => setPrice(e.target.value)}
                required
                className="w-full px-4 py-2.5 bg-white border border-zinc-200 rounded-xl text-zinc-850 focus:outline-hidden focus:border-indigo-500"
              />
            </div>
            <div className="space-y-1.5">
              <label className="font-bold text-zinc-500 uppercase tracking-wider block">Số lượng kho</label>
              <input
                type="number"
                value={stock}
                onChange={(e) => setStock(parseInt(e.target.value) || 0)}
                required
                className="w-full px-4 py-2.5 bg-white border border-zinc-200 rounded-xl text-zinc-850 focus:outline-hidden focus:border-indigo-500"
              />
            </div>
          </div>

          {/* Image Upload */}
          <div className="space-y-1.5">
            <label className="font-bold text-zinc-500 uppercase tracking-wider block">Ảnh sản phẩm</label>
            <div className="flex items-center gap-3">
              <label className="px-4 py-2.5 bg-slate-50 hover:bg-slate-100 border border-zinc-200 rounded-xl cursor-pointer flex items-center gap-1.5 text-zinc-650 transition-colors">
                <Upload className="w-4 h-4" />
                <span>{uploadingImage ? "Đang tải..." : "Tải ảnh lên"}</span>
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleImageUpload}
                  className="hidden"
                />
              </label>
              {imageUrl && (
                <span className="text-[10px] text-green-600 flex items-center gap-1">
                  <CheckCircle className="w-3.5 h-3.5" />
                  <span>Đã nhận ảnh</span>
                </span>
              )}
            </div>
          </div>

          {/* Description */}
          <div className="space-y-1.5">
            <label className="font-bold text-zinc-500 uppercase tracking-wider block">Mô tả sản phẩm</label>
            <textarea
              placeholder="Nhập thông số kỹ thuật, mô tả nổi bật..."
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              rows={3}
              className="w-full px-4 py-2.5 bg-white border border-zinc-200 rounded-xl text-zinc-850 focus:outline-hidden focus:border-indigo-500"
            />
          </div>

          {/* Submit */}
          <button
            type="submit"
            disabled={loading}
            className="w-full py-3 bg-linear-to-r from-indigo-550 to-violet-550 text-white font-semibold rounded-xl shadow-lg shadow-indigo-500/15 hover:from-indigo-600 hover:to-violet-600 transition-all flex items-center justify-center gap-1 cursor-pointer disabled:opacity-50"
          >
            {loading ? (
              <span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></span>
            ) : (
              <span>Lưu sản phẩm</span>
            )}
          </button>
        </form>
      </div>

      {/* 2. Danh Sách Sản Phẩm */}
      <div className="lg:col-span-2 space-y-4">
        <div className="bg-white border border-zinc-200/80 rounded-3xl shadow-xs overflow-hidden">
          <div className="px-6 py-4 bg-slate-50/30 border-b border-zinc-150 font-bold text-zinc-700">
            Sản phẩm đang kinh doanh
          </div>
          
          {productsList.length === 0 ? (
            <div className="text-center py-20 text-zinc-400">
              Không có sản phẩm nào.
            </div>
          ) : (
            <div className="divide-y divide-zinc-100">
              {productsList.map((product) => (
                <div key={product.id} className="p-6 flex items-center justify-between gap-4 hover:bg-slate-50/20 transition-colors">
                  <div className="flex items-center gap-4">
                    <div className="w-10 h-10 bg-slate-50 rounded-lg flex items-center justify-center text-zinc-350 border border-zinc-100">
                      <ImageIcon className="w-5 h-5" />
                    </div>
                    <div>
                      <h4 className="font-bold text-sm text-zinc-800">{product.name}</h4>
                      <div className="flex items-center gap-4 text-xs text-zinc-500 mt-1">
                        <span className="flex items-center gap-1">
                          <Tag className="w-3.5 h-3.5 text-zinc-400" />
                          <span>{parseFloat(product.price).toLocaleString("vi-VN")} đ</span>
                        </span>
                        <span className="flex items-center gap-1">
                          <Database className="w-3.5 h-3.5 text-zinc-400" />
                          <span>Kho: {product.stock}</span>
                        </span>
                      </div>
                    </div>
                  </div>

                  <button
                    onClick={() => handleDelete(product.id)}
                    className="p-2 hover:bg-red-500/5 text-zinc-450 hover:text-red-600 rounded-xl transition-colors cursor-pointer"
                    title="Xóa sản phẩm"
                  >
                    <Trash2 className="w-4.5 h-4.5" />
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
