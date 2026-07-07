import { Order } from "./types";

/**
 * Generate a beautifully formatted HTML invoice email for Poyken Sound customers.
 */
export function generateInvoiceEmailHtml(order: Order): string {
  const orderCode = order.id.substring(4, 12).toUpperCase();
  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price);
  };

  const itemsList = order.items
    .map(
      (item) => `
      <tr>
        <td style="padding: 12px; border-bottom: 1px solid #e7e5e4; font-weight: bold; color: #1c1917;">
          ${item.product?.name || "Thiết bị loa"} <span style="font-weight: normal; font-size: 11px; color: #78716c;">(${item.product?.brand})</span>
        </td>
        <td style="padding: 12px; border-bottom: 1px solid #e7e5e4; text-align: center; color: #44403c;">
          ${item.quantity}
        </td>
        <td style="padding: 12px; border-bottom: 1px solid #e7e5e4; text-align: right; color: #44403c;">
          ${formatPrice(item.price)}
        </td>
        <td style="padding: 12px; border-bottom: 1px solid #e7e5e4; text-align: right; font-weight: bold; color: #c2410c;">
          ${formatPrice(item.price * item.quantity)}
        </td>
      </tr>`
    )
    .join("");

  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <title>Hóa Đơn Đơn Hàng Poyken Sound #${orderCode}</title>
    </head>
    <body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #fbfbf9; color: #1c1917;">
      <div style="max-width: 600px; margin: 20px auto; background-color: #ffffff; border: 1px solid #e7e5e4; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.03);">
        
        <!-- Header Banner -->
        <div style="background-color: #1c1917; padding: 30px; text-align: center;">
          <h1 style="color: #ffffff; margin: 0; font-size: 22px; font-weight: 900; letter-spacing: 4px; text-transform: uppercase;">
            POYKEN<span style="color: #c2410c;">SOUND</span>
          </h1>
          <p style="color: #a8a29e; margin: 5px 0 0 0; font-size: 10px; font-weight: bold; letter-spacing: 2px; text-transform: uppercase;">
            Premium Audio Systems
          </p>
        </div>

        <!-- Content Area -->
        <div style="padding: 30px;">
          <h2 style="margin-top: 0; color: #1c1917; font-size: 20px; font-weight: 800; text-transform: uppercase;">Cảm ơn bạn đã đặt hàng!</h2>
          <p style="font-size: 14px; color: #44403c; line-height: 1.6;">
            Chào <strong>${order.customerName}</strong>, đơn hàng số <strong>#${orderCode}</strong> của bạn đã được hệ thống Poyken Sound tiếp nhận thành công. Dưới đây là thông tin chi tiết hóa đơn mua sắm của bạn:
          </p>

          <!-- Order info boxes -->
          <table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
            <tr>
              <td style="width: 50%; padding: 15px; background-color: #f5f5f4; border-radius: 12px; border: 1px solid #e7e5e4; vertical-align: top;">
                <h4 style="margin: 0 0 8px 0; color: #1c1917; font-size: 12px; text-transform: uppercase; font-weight: bold;">Địa Chỉ Giao Hàng</h4>
                <p style="margin: 0; font-size: 12px; color: #44403c; line-height: 1.4;">
                  SĐT: ${order.customerPhone}<br>
                  ĐC: ${order.address}
                </p>
              </td>
              <td style="width: 50%; padding: 15px; background-color: #f5f5f4; border-radius: 12px; border: 1px solid #e7e5e4; vertical-align: top; margin-left: 10px;">
                <h4 style="margin: 0 0 8px 0; color: #1c1917; font-size: 12px; text-transform: uppercase; font-weight: bold;">Thanh Toán</h4>
                <p style="margin: 0; font-size: 12px; color: #44403c; line-height: 1.4;">
                  Phương thức: <strong>${order.paymentMethod === "COD" ? "Thanh toán khi nhận hàng (COD)" : "Chuyển khoản Ngân hàng (QR)"}</strong><br>
                  Trạng thái: <strong style="color: #b45309;">${order.status}</strong>
                </p>
              </td>
            </tr>
          </table>

          <!-- Items Table -->
          <table style="width: 100%; border-collapse: collapse; font-size: 13px;">
            <thead>
              <tr style="background-color: #f5f5f4; border-bottom: 2px solid #e7e5e4;">
                <th style="padding: 10px 12px; text-align: left; font-weight: bold; color: #78716c; text-transform: uppercase; font-size: 10px;">Loa</th>
                <th style="padding: 10px 12px; text-align: center; font-weight: bold; color: #78716c; text-transform: uppercase; font-size: 10px; width: 10%;">SL</th>
                <th style="padding: 10px 12px; text-align: right; font-weight: bold; color: #78716c; text-transform: uppercase; font-size: 10px; width: 25%;">Đơn giá</th>
                <th style="padding: 10px 12px; text-align: right; font-weight: bold; color: #78716c; text-transform: uppercase; font-size: 10px; width: 25%;">Thành tiền</th>
              </tr>
            </thead>
            <tbody>
              ${itemsList}
            </tbody>
            <tfoot>
              <tr>
                <td colspan="2" style="padding: 15px 12px; font-weight: bold; font-size: 14px; text-align: right; color: #44403c;">Cần Thanh Toán:</td>
                <td colspan="2" style="padding: 15px 12px; font-weight: 900; font-size: 18px; text-align: right; color: #c2410c;">
                  ${formatPrice(order.total)}
                </td>
              </tr>
            </tfoot>
          </table>
          
          <div style="margin-top: 30px; padding: 15px; border-top: 1px dashed #e7e5e4; text-align: center; font-size: 11px; color: #78716c;">
            Nếu bạn chọn chuyển khoản ngân hàng, hướng dẫn quét mã QR thanh toán chi tiết sẽ được nhân viên tư vấn gửi tới bạn trong vòng vài phút. Hotline hỗ trợ 24/7: 1900 8080.
          </div>
        </div>

        <!-- Footer bar -->
        <div style="background-color: #f5f5f4; padding: 20px; text-align: center; font-size: 10px; color: #a8a29e; border-top: 1px solid #e7e5e4;">
          © ${new Date().getFullYear()} POYKEN SOUND. Số 18, Đường 3/2, Quận 10, TP. Hồ Chí Minh
        </div>

      </div>
    </body>
    </html>
  `;
}

/**
 * Generate HTML alert email for the shop owner/admin on a new purchase.
 */
export function generateAdminNotificationEmailHtml(order: Order): string {
  const orderCode = order.id.substring(4, 12).toUpperCase();
  return `
    <!DOCTYPE html>
    <html>
    <body>
      <div style="max-width: 500px; margin: 0 auto; font-family: sans-serif; border: 1px solid #ccc; padding: 20px; border-radius: 8px;">
        <h2 style="color: #c2410c; margin-top: 0;">🛎️ ĐƠN HÀNG MỚI ĐÃ NHẬN</h2>
        <p>Hệ thống Poyken Sound vừa ghi nhận một giao dịch đặt hàng mới:</p>
        <ul>
          <li><strong>Mã đơn hàng:</strong> #${orderCode}</li>
          <li><strong>Khách hàng:</strong> ${order.customerName}</li>
          <li><strong>Số điện thoại:</strong> ${order.customerPhone}</li>
          <li><strong>Địa chỉ:</strong> ${order.address}</li>
          <li><strong>Tổng tiền:</strong> ${order.total.toLocaleString("vi-VN")} ₫</li>
          <li><strong>Thanh toán:</strong> ${order.paymentMethod}</li>
        </ul>
        <p>Vui lòng đăng nhập vào trang <a href="${process.env.NEXTAUTH_URL || 'http://localhost:3000'}/admin">Admin Dashboard</a> để xem chi tiết và duyệt đơn.</p>
      </div>
    </body>
    </html>
  `;
}

/**
 * Send order emails using Resend HTTP api or fallback to console log simulation.
 */
export async function sendOrderEmails(order: Order): Promise<boolean> {
  const apiKey = process.env.RESEND_API_KEY;
  const sender = process.env.SENDER_EMAIL || "orders@poykensound.vn";
  const adminEmail = process.env.ADMIN_EMAIL || "admin@poykensound.vn";
  const orderCode = order.id.substring(4, 12).toUpperCase();

  const customerHtml = generateInvoiceEmailHtml(order);
  const adminHtml = generateAdminNotificationEmailHtml(order);

  // Fallback to console logs if no API key configured (development testing mode)
  if (!apiKey || apiKey === "placeholder") {
    console.log("\n========================================================");
    console.log(`[Email Simulation] Gửi hóa đơn #${orderCode} tới Khách hàng: ${order.customerEmail}`);
    console.log(`[Email Simulation] Gửi cảnh báo bán hàng mới tới Admin: ${adminEmail}`);
    console.log("========================================================\n");
    return true;
  }

  try {
    // 1. Send Customer Invoice
    const customerRes = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        from: `Poyken Sound <${sender}>`,
        to: order.customerEmail,
        subject: `Hóa đơn đặt hàng Poyken Sound #${orderCode}`,
        html: customerHtml,
      }),
    });

    // 2. Send Admin Alert
    const adminRes = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        from: `Poyken Sound Systems <${sender}>`,
        to: adminEmail,
        subject: `[Đơn hàng mới] #${orderCode} - ${order.customerName}`,
        html: adminHtml,
      }),
    });

    return customerRes.ok && adminRes.ok;
  } catch (error) {
    console.error("Resend API failed to send order emails:", error);
    return false;
  }
}
