import { db } from "@/db/db";
import { orders, auditLogs } from "@/db/schema";
import { eq } from "drizzle-orm";
import { NextResponse } from "next/server";
import crypto from "crypto";

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    
    // Lấy secure hash từ VNPAY gửi sang
    const vnp_SecureHash = searchParams.get("vnp_SecureHash");
    
    // Lọc bỏ secure hash ra để tính toán lại chữ ký
    const params: Record<string, string> = {};
    searchParams.forEach((value, key) => {
      if (key !== "vnp_SecureHash" && key !== "vnp_SecureHashType") {
        params[key] = value;
      }
    });

    // 1. Xác thực Chữ ký Số (Signature Verification)
    const hashSecret = process.env.VNPAY_HASH_SECRET || "97298642a8b981cd58117769910d655b";
    
    const sortedKeys = Object.keys(params).sort();
    const signData = sortedKeys
      .map((key) => `${key}=${encodeURIComponent(params[key]).replace(/%20/g, "+")}`)
      .join("&");

    const hmac = crypto.createHmac("sha512", hashSecret);
    const calculatedHash = hmac.update(Buffer.from(signData, "utf-8")).digest("hex");

    if (calculatedHash !== vnp_SecureHash) {
      console.error("VNPAY IPN Signature verification failed.");
      return NextResponse.json({ RspCode: "97", Message: "Invalid Signature" });
    }

    const orderId = params["vnp_TxnRef"];
    const responseCode = params["vnp_ResponseCode"];
    const vnpAmount = parseFloat(params["vnp_Amount"]) / 100;

    // 2. Kiểm tra xem Đơn hàng có tồn tại trong Database không
    const dbOrders = await db.select().from(orders).where(eq(orders.id, orderId));
    const order = dbOrders[0];

    if (!order) {
      return NextResponse.json({ RspCode: "01", Message: "Order not found" });
    }

    // 3. Kiểm tra xem đơn hàng đã được cập nhật trạng thái thanh toán trước đó chưa (Chống trùng lặp - Idempotency)
    if (order.paymentStatus === "paid") {
      return NextResponse.json({ RspCode: "02", Message: "Order already confirmed" });
    }

    // 4. Xử lý cập nhật trạng thái thanh toán đơn hàng
    if (responseCode === "00") {
      await db.transaction(async (tx) => {
        await tx
          .update(orders)
          .set({
            paymentStatus: "paid",
            status: "paid",
          })
          .where(eq(orders.id, orderId));

        // Ghi nhận lịch sử giao dịch thành công
        await tx.insert(auditLogs).values({
          action: "payment_success_vnpay_ipn",
          entityName: "orders",
          entityId: orderId,
          newValues: {
            vnp_TransactionNo: params["vnp_TransactionNo"],
            vnp_PayDate: params["vnp_PayDate"],
            vnp_BankCode: params["vnp_BankCode"],
          },
        });
      });

      // Kích hoạt tác vụ nền gửi email hóa đơn
      const appUrl = process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000";
      const jobSecret = process.env.INTERNAL_JOB_SECRET || "local_job_secret_123";
      fetch(`${appUrl}/api/jobs/send-email?orderId=${orderId}`, {
        method: "POST",
        headers: {
          "x-job-secret": jobSecret,
        },
      }).catch((err) => console.error("Lỗi kích hoạt gửi email:", err));

      return NextResponse.json({ RspCode: "00", Message: "Confirm success" });
    } else {
      // Thanh toán thất bại
      await db.transaction(async (tx) => {
        await tx
          .update(orders)
          .set({
            status: "cancelled",
            paymentStatus: "unpaid",
          })
          .where(eq(orders.id, orderId));

        await tx.insert(auditLogs).values({
          action: "payment_failed_vnpay_ipn",
          entityName: "orders",
          entityId: orderId,
          newValues: { vnp_ResponseCode: responseCode },
        });
      });

      return NextResponse.json({ RspCode: "00", Message: "Confirm success (payment failed)" });
    }
  } catch (error: any) {
    console.error("Lỗi xử lý VNPAY IPN:", error);
    return NextResponse.json({ RspCode: "99", Message: "Unknow error" }, { status: 500 });
  }
}
