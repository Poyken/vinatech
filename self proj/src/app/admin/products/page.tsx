import React from "react";
import { db } from "@/db/db";
import { products, categories } from "@/db/schema";
import { isNull, desc } from "drizzle-orm";
import ProductsManager from "./ProductsManager";

export const revalidate = 0; // Vô hiệu hóa cache cho trang quản trị sản phẩm

export default async function AdminProductsPage() {
  // Lấy các sản phẩm đang active (chưa bị xóa)
  const dbProducts = await db
    .select()
    .from(products)
    .where(isNull(products.deletedAt))
    .orderBy(desc(products.createdAt));

  // Lấy danh sách danh mục
  const dbCategories = await db.select().from(categories);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-extrabold tracking-tight text-zinc-900">Quản lý Sản phẩm</h1>
        <p className="text-sm text-zinc-500 mt-1">
          Thêm sản phẩm mới, upload hình ảnh, thay đổi giá bán và kiểm kho tồn kho.
        </p>
      </div>

      <ProductsManager 
        initialProducts={dbProducts} 
        categories={dbCategories} 
      />
    </div>
  );
}
