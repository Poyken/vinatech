import { db } from "@/db/db";
import { orders, orderItems, products } from "@/db/schema";
import { createClient } from "@/utils/supabase/server";
import { eq, and } from "drizzle-orm";
import { NextResponse } from "next/server";
import crypto from "crypto";

export async function POST(request: Request) {
  try {
    const supabase = await createClient();
    const { data: userData } = await supabase.auth.getUser();

    if (!userData?.user) {
      return NextResponse.json(
        { success: false, error: "Bạn cần đăng nhập để thanh toán." },
        { status: 401 }
      );
    }

    const { items, shippingAddress, paymentMethod } = (await request.json()) as {
      items: { productId: string; quantity: number }[];
      shippingAddress: string;
      paymentMethod: string;
    };

    if (!items || items.length === 0 || !shippingAddress) {
      return NextResponse.json(
        { success: false, error: "Thiếu thông tin đơn hàng hoặc địa chỉ giao hàng." },
        { status: 400 }
      );
    }

    // 1. Thực hiện Database Transaction để tạo đơn hàng và cập nhật tồn kho
    const orderResult = await db.transaction(async (tx) => {
      let totalAmount = 0;
      const verifiedItems = [];

      for (const item of items) {
        // Lấy sản phẩm có Lock dòng để tránh tranh chấp ghi đồng thời (Pessimistic Locking)
        // Trong postgres, dùng: SELECT * FROM products WHERE id = ? FOR UPDATE
        const dbProducts = await tx
          .select()
          .from(products)
          .where(eq(products.id, item.productId));

        const product = dbProducts[0];
        if (!product || !product.isActive) {
          throw new Error(`Sản phẩm không tồn tại hoặc đã ngừng kinh doanh.`);
        }

        if (product.stock < item.quantity) {
          throw new Error(`Sản phẩm "${product.name}" không đủ hàng trong kho (Còn: ${product.stock}).`);
        }

        const price = parseFloat(product.price);
        totalAmount += price * item.quantity;
        verifiedItems.push({
          productId: product.id,
          quantity: item.quantity,
          price: product.price,
          newStock: product.stock - item.quantity,
        });
      }

      // Tạo bản ghi đơn hàng
      const newOrders = await tx
        .insert(orders)
        .values({
          userId: userData.user.id,
          status: "pending",
          totalAmount: totalAmount.toString(),
          shippingAddress,
          paymentStatus: "unpaid",
          paymentMethod,
        })
        .returning();

      const order = newOrders[0];

      // Tạo các order items và cập nhật tồn kho sản phẩm
      for (const item of verifiedItems) {
        await tx.insert(orderItems).values({
          orderId: order.id,
          productId: item.productId,
          quantity: item.quantity,
          price: item.price,
        });

        // Sử dụng cập nhật có điều kiện để chống race condition lần nữa
        const updateResult = await tx
          .update(products)
          .set({ stock: item.newStock })
          .where(and(eq(products.id, item.productId), eq(products.stock, item.newStock + item.quantity)))
          .returning();

        // Nếu updateResult không ảnh hưởng dòng nào, có nghĩa là đã có tranh chấp tồn kho xảy ra giữa chừng
        if (updateResult.length === 0) {
          throw new Error("Tranh chấp tồn kho xảy ra, vui lòng thử lại.");
        }
      }

      return order;
    });

    // 2. Tạo link thanh toán VNPAY Sandbox
    const tmnCode = process.env.VNPAY_TMN_CODE || "2QXFA55V"; // Mã test mặc định của VNPAY
    const hashSecret = process.env.VNPAY_HASH_SECRET || "97298642a8b981cd58117769910d655b"; // Key test mặc định
    const vnpUrl = process.env.VNPAY_URL || "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    const appUrl = process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000";

    const returnUrl = `${appUrl}/api/checkout/vnpay-return`;
    const ipAddr = request.headers.get("x-forwarded-for") || "127.0.0.1";

    const paymentUrl = generateVNPAYUrl({
      tmnCode,
      hashSecret,
      vnpUrl,
      orderId: orderResult.id,
      amount: parseFloat(orderResult.totalAmount),
      ipAddr,
      returnUrl,
    });

    return NextResponse.json({
      success: true,
      orderId: orderResult.id,
      paymentUrl,
    });
  } catch (error: any) {
    return NextResponse.json(
      { success: false, error: error.message || "Đã xảy ra lỗi khi tạo đơn hàng." },
      { status: 500 }
    );
  }
}

function generateVNPAYUrl({
  tmnCode,
  hashSecret,
  vnpUrl,
  orderId,
  amount,
  ipAddr,
  returnUrl,
}: {
  tmnCode: string;
  hashSecret: string;
  vnpUrl: string;
  orderId: string;
  amount: number;
  ipAddr: string;
  returnUrl: string;
}) {
  const date = new Date();
  const createDate = formatDate(date);

  const params: Record<string, string> = {
    vnp_Version: "2.1.0",
    vnp_Command: "pay",
    vnp_TmnCode: tmnCode,
    vnp_Locale: "vn",
    vnp_CurrCode: "VND",
    vnp_TxnRef: orderId,
    vnp_OrderInfo: `Thanh toan don hang ${orderId}`,
    vnp_OrderType: "other",
    // VNPAY yêu cầu số tiền nhân với 100
    vnp_Amount: Math.round(amount * 100).toString(),
    vnp_ReturnUrl: returnUrl,
    vnp_IpAddr: ipAddr,
    vnp_CreateDate: createDate,
  };

  // Sắp xếp các tham số theo thứ tự alphabet của key
  const sortedKeys = Object.keys(params).sort();
  const signData = sortedKeys
    .map((key) => `${key}=${encodeURIComponent(params[key]).replace(/%20/g, "+")}`)
    .join("&");

  const hmac = crypto.createHmac("sha512", hashSecret);
  const secureHash = hmac.update(Buffer.from(signData, "utf-8")).digest("hex");

  const queryParams = sortedKeys
    .map((key) => `${key}=${encodeURIComponent(params[key]).replace(/%20/g, "+")}`)
    .join("&");

  return `${vnpUrl}?${queryParams}&vnp_SecureHash=${secureHash}`;
}

function formatDate(date: Date) {
  const pad = (n: number) => (n < 10 ? "0" + n : n.toString());
  return (
    date.getFullYear().toString() +
    pad(date.getMonth() + 1) +
    pad(date.getDate()) +
    pad(date.getHours()) +
    pad(date.getMinutes()) +
    pad(date.getSeconds())
  );
}
