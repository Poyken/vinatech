"use server";

import { db } from "@/db/db";
import { orders, products, auditLogs } from "@/db/schema";
import { eq } from "drizzle-orm";
import { revalidatePath } from "next/cache";

// 1. Cập nhật trạng thái đơn hàng (Có ghi nhận Audit Logs)
export async function updateOrderStatus(orderId: string, status: string, userId?: string) {
  try {
    const dbOrders = await db.select().from(orders).where(eq(orders.id, orderId));
    const order = dbOrders[0];

    if (!order) {
      return { success: false, error: "Không tìm thấy đơn hàng." };
    }

    // Cập nhật trạng thái
    await db
      .update(orders)
      .set({ status })
      .where(eq(orders.id, orderId));

    // Ghi nhận Audit Log
    await db.insert(auditLogs).values({
      userId: userId || null,
      action: "update_order_status",
      entityName: "orders",
      entityId: orderId,
      oldValues: { status: order.status },
      newValues: { status },
    });

    revalidatePath("/admin");
    return { success: true };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
}

// 2. Tạo sản phẩm mới
export async function createProduct(formData: {
  name: string;
  slug: string;
  categoryId: string;
  description: string;
  price: string;
  stock: number;
}) {
  try {
    if (!formData.name || !formData.slug || !formData.price) {
      return { success: false, error: "Vui lòng nhập tên, slug và giá bán sản phẩm." };
    }

    await db.insert(products).values({
      name: formData.name,
      slug: formData.slug,
      categoryId: formData.categoryId || null,
      description: formData.description,
      price: formData.price,
      stock: formData.stock,
      isActive: true,
    });

    revalidatePath("/");
    revalidatePath("/admin/products");
    return { success: true };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
}

// 3. Xóa mềm sản phẩm
export async function deleteProduct(productId: string) {
  try {
    await db
      .update(products)
      .set({ deletedAt: new Date(), isActive: false })
      .where(eq(products.id, productId));

    revalidatePath("/");
    revalidatePath("/admin/products");
    return { success: true };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
}
