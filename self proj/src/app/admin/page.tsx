import React from "react";
import { db } from "@/db/db";
import { orders } from "@/db/schema";
import { desc } from "drizzle-orm";
import OrdersTable from "./OrdersTable";

export const revalidate = 0; // Vô hiệu hóa cache cho dashboard của Admin

export default async function AdminDashboardPage() {
  // Lấy danh sách toàn bộ đơn hàng
  const dbOrders = await db
    .select()
    .from(orders)
    .orderBy(desc(orders.createdAt));

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-extrabold tracking-tight text-zinc-900">Quản lý Đơn hàng</h1>
        <p className="text-sm text-zinc-500 mt-1">
          Theo dõi trạng thái thanh toán và cập nhật quá trình vận chuyển đơn hàng.
        </p>
      </div>

      <OrdersTable initialOrders={dbOrders} />
    </div>
  );
}
