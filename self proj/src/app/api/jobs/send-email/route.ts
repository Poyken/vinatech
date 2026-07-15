import { db } from "@/db/db";
import { orders, users } from "@/db/schema";
import { eq } from "drizzle-orm";
import { NextResponse } from "next/server";

export async function POST(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const orderId = searchParams.get("orderId");

    // 1. Xác thực bảo mật: Chỉ cho phép QStash hoặc Token nội bộ gọi endpoint này
    const qstashSignature = request.headers.get("upstash-signature");
    const internalSecret = request.headers.get("x-job-secret");
    
    const expectedSecret = process.env.INTERNAL_JOB_SECRET || "local_job_secret_123";

    if (!qstashSignature && internalSecret !== expectedSecret) {
      return NextResponse.json(
        { success: false, error: "Không có quyền truy cập endpoint này." },
        { status: 401 }
      );
    }

    if (!orderId) {
      return NextResponse.json(
        { success: false, error: "Thiếu mã đơn hàng." },
        { status: 450 }
      );
    }

    // 2. Lấy thông tin đơn hàng và thông tin người dùng
    const dbOrders = await db.select().from(orders).where(eq(orders.id, orderId));
    const order = dbOrders[0];

    if (!order) {
      return NextResponse.json(
        { success: false, error: "Không tìm thấy đơn hàng." },
        { status: 404 }
      );
    }

    if (!order.userId) {
      return NextResponse.json(
        { success: false, error: "Đơn hàng không có thông tin người dùng." },
        { status: 400 }
      );
    }

    const dbUsers = await db.select().from(users).where(eq(users.id, order.userId));
    const user = dbUsers[0];

    if (!user || !user.email) {
      return NextResponse.json(
        { success: false, error: "Không tìm thấy email người dùng." },
        { status: 404 }
      );
    }

    // 3. Gọi dịch vụ Resend gửi email xác nhận hóa đơn
    const resendApiKey = process.env.RESEND_API_KEY;

    if (!resendApiKey) {
      console.warn("Chưa cấu hình RESEND_API_KEY. Bỏ qua bước gửi mail.");
      return NextResponse.json({
        success: true,
        message: "Chưa cấu hình RESEND_API_KEY. Code logic gửi email đã sẵn sàng.",
      });
    }

    const emailResponse = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${resendApiKey}`,
      },
      body: JSON.stringify({
        from: "Vinatech Shop <onboarding@resend.dev>", // Tên thương hiệu hiển thị
        to: user.email,
        subject: `Hóa đơn thanh toán đơn hàng #${order.id} - Vinatech Shop`,
        html: `
          <div style="font-family: sans-serif; padding: 20px; color: #333; max-width: 600px; margin: auto; border: 1px solid #eee; border-radius: 10px;">
            <h2 style="color: #6366f1; text-align: center;">Cảm ơn bạn đã mua hàng!</h2>
            <p>Xin chào <strong>${user.fullName || "khách hàng"}</strong>,</p>
            <p>Chúng tôi đã nhận được thanh toán cho đơn hàng của bạn. Dưới đây là thông tin chi tiết hóa đơn:</p>
            
            <div style="background-color: #f9fafb; padding: 15px; border-radius: 8px; margin: 20px 0;">
              <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
                <tr>
                  <td style="padding: 5px 0; color: #6b7280;">Mã đơn hàng:</td>
                  <td style="padding: 5px 0; font-family: monospace; font-weight: bold; text-align: right;">${order.id}</td>
                </tr>
                <tr>
                  <td style="padding: 5px 0; color: #6b7280;">Phương thức thanh toán:</td>
                  <td style="padding: 5px 0; text-align: right; text-transform: uppercase;">${order.paymentMethod}</td>
                </tr>
                <tr>
                  <td style="padding: 5px 0; color: #6b7280;">Địa chỉ giao hàng:</td>
                  <td style="padding: 5px 0; text-align: right;">${order.shippingAddress}</td>
                </tr>
                <tr style="border-top: 1px solid #e5e7eb; font-weight: bold; font-size: 16px;">
                  <td style="padding: 10px 0 0 0; color: #111827;">Tổng tiền thanh toán:</td>
                  <td style="padding: 10px 0 0 0; color: #6366f1; text-align: right;">${parseFloat(order.totalAmount).toLocaleString("vi-VN")} đ</td>
                </tr>
              </table>
            </div>

            <p style="font-size: 12px; color: #9ca3af; text-align: center; margin-top: 40px;">
              © 2026 Vinatech Shop. Mọi thắc mắc xin liên hệ bộ phận hỗ trợ khách hàng.
            </p>
          </div>
        `,
      }),
    });

    const emailJson = await emailResponse.json();

    if (!emailResponse.ok) {
      console.error("Lỗi từ Resend API:", emailJson);
      return NextResponse.json({ success: false, error: emailJson }, { status: 400 });
    }

    return NextResponse.json({ success: true, data: emailJson });
  } catch (error: any) {
    console.error("Lỗi xảy ra trong send-email job:", error);
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}
