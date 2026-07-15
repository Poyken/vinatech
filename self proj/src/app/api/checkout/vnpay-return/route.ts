import { db } from "@/db/db";
import { orders, auditLogs } from "@/db/schema";
import { eq } from "drizzle-orm";
import { NextResponse } from "next/server";
import crypto from "crypto";

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    
    // Lấy secure hash từ VNPAY
    const vnp_SecureHash = searchParams.get("vnp_SecureHash");
    
    // Bản sao các tham số để verify signature
    const params: Record<string, string> = {};
    searchParams.forEach((value, key) => {
      if (key !== "vnp_SecureHash" && key !== "vnp_SecureHashType") {
        params[key] = value;
      }
    });

    // 1. Kiểm tra chữ ký bảo mật từ VNPAY
    const hashSecret = process.env.VNPAY_HASH_SECRET || "97298642a8b981cd58117769910d655b";
    
    const sortedKeys = Object.keys(params).sort();
    const signData = sortedKeys
      .map((key) => `${key}=${encodeURIComponent(params[key]).replace(/%20/g, "+")}`)
      .join("&");

    const hmac = crypto.createHmac("sha512", hashSecret);
    const calculatedHash = hmac.update(Buffer.from(signData, "utf-8")).digest("hex");

    const appUrl = process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000";

    if (calculatedHash !== vnp_SecureHash) {
      console.error("VNPAY Return Signature mismatch.");
      return NextResponse.redirect(`${appUrl}/checkout/result?success=false&error=invalid_signature`);
    }

    const orderId = params["vnp_TxnRef"];
    const responseCode = params["vnp_ResponseCode"];
    const amount = parseFloat(params["vnp_Amount"]) / 100;

    if (responseCode === "00") {
      // 2. Thanh toán thành công -> Cập nhật Database
      await db.transaction(async (tx) => {
        const dbOrders = await tx.select().from(orders).where(eq(orders.id, orderId));
        const order = dbOrders[0];

        if (!order) {
          throw new Error("Không tìm thấy đơn hàng tương ứng.");
        }

        // Chỉ cập nhật nếu đơn hàng chưa thanh toán (Tránh cập nhật trùng lặp)
        if (order.paymentStatus !== "paid") {
          await tx
            .update(orders)
            .set({
              paymentStatus: "paid",
              status: "paid",
            })
            .where(eq(orders.id, orderId));

          // Ghi audit log giao dịch
          await tx.insert(auditLogs).values({
            action: "payment_success_vnpay",
            entityName: "orders",
            entityId: orderId,
            newValues: {
              vnp_Amount: params["vnp_Amount"],
              vnp_TransactionNo: params["vnp_TransactionNo"],
              vnp_PayDate: params["vnp_PayDate"],
            },
          });

          // Kích hoạt tác vụ nền gửi email hóa đơn
          const jobSecret = process.env.INTERNAL_JOB_SECRET || "local_job_secret_123";
          fetch(`${appUrl}/api/jobs/send-email?orderId=${orderId}`, {
            method: "POST",
            headers: {
              "x-job-secret": jobSecret,
            },
          }).catch((err) => console.error("Lỗi kích hoạt gửi email:", err));
        }
      });

      return NextResponse.redirect(`${appUrl}/checkout/result?success=true&orderId=${orderId}`);
    } else {
      // Thanh toán thất bại -> Cập nhật trạng thái cancel/failed nếu cần
      await db.transaction(async (tx) => {
        await tx
          .update(orders)
          .set({
            status: "cancelled",
            paymentStatus: "unpaid",
          })
          .where(eq(orders.id, orderId));

        await tx.insert(auditLogs).values({
          action: "payment_failed_vnpay",
          entityName: "orders",
          entityId: orderId,
          newValues: { vnp_ResponseCode: responseCode },
        });
      });

      return NextResponse.redirect(
        `${appUrl}/checkout/result?success=false&orderId=${orderId}&code=${responseCode}`
      );
    }
  } catch (error: any) {
    console.error("Error handling VNPAY return:", error);
    const appUrl = process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000";
    return NextResponse.redirect(`${appUrl}/checkout/result?success=false&error=system_error`);
  }
}
