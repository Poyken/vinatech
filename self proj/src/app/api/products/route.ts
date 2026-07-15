import { db } from "@/db/db";
import { products } from "@/db/schema";
import { eq, and, lte, gte, ilike } from "drizzle-orm";
import { NextResponse } from "next/server";

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const categoryId = searchParams.get("categoryId");
    const query = searchParams.get("query");
    const minPrice = searchParams.get("minPrice");
    const maxPrice = searchParams.get("maxPrice");

    // Chỉ lấy sản phẩm chưa bị xóa và đang active
    const conditions = [
      eq(products.isActive, true),
    ];

    if (categoryId) {
      conditions.push(eq(products.categoryId, categoryId));
    }
    if (query) {
      // ilike hỗ trợ tìm kiếm không phân biệt hoa thường trong PostgreSQL
      conditions.push(ilike(products.name, `%${query}%`));
    }
    if (minPrice) {
      conditions.push(gte(products.price, minPrice));
    }
    if (maxPrice) {
      conditions.push(lte(products.price, maxPrice));
    }

    const data = await db
      .select()
      .from(products)
      .where(and(...conditions))
      .orderBy(products.name);

    return NextResponse.json({ success: true, data });
  } catch (error: any) {
    return NextResponse.json(
      { success: false, error: error.message || "Đã xảy ra lỗi khi lấy danh sách sản phẩm." },
      { status: 500 }
    );
  }
}
