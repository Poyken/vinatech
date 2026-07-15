import { db } from "@/db/db";
import { products } from "@/db/schema";
import { eq, and } from "drizzle-orm";
import { NextResponse } from "next/server";

export async function GET(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params; // Lấy params dạng Promise trong Next.js 16

    const data = await db
      .select()
      .from(products)
      .where(and(eq(products.id, id), eq(products.isActive, true)))
      .limit(1);

    if (data.length === 0) {
      return NextResponse.json(
        { success: false, error: "Không tìm thấy sản phẩm hoặc sản phẩm không còn hoạt động." },
        { status: 404 }
      );
    }

    return NextResponse.json({ success: true, data: data[0] });
  } catch (error: any) {
    return NextResponse.json(
      { success: false, error: error.message || "Đã xảy ra lỗi khi lấy thông tin sản phẩm." },
      { status: 500 }
    );
  }
}
