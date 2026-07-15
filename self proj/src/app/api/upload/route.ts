import { NextRequest, NextResponse } from "next/server";
import { r2Client, isR2Configured } from "@/utils/r2";
import { PutObjectCommand } from "@aws-sdk/client-s3";
import { promises as fs } from "fs";
import path from "path";
import crypto from "crypto";

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData();
    const file = formData.get("file") as File;

    if (!file) {
      return NextResponse.json(
        { success: false, error: "Vui lòng đính kèm một file ảnh." },
        { status: 400 }
      );
    }

    const buffer = Buffer.from(await file.arrayBuffer());
    
    // Tạo tên file duy nhất tránh trùng lặp
    const fileExtension = path.extname(file.name) || ".jpg";
    const uniqueFilename = `${crypto.randomUUID()}${fileExtension}`;

    // --- CHẾ ĐỘ 1: Cloudflare R2 nếu đã được cấu hình ---
    if (isR2Configured && r2Client) {
      const bucketName = process.env.R2_BUCKET_NAME || "vinatech-ecommerce";
      const customDomain = process.env.R2_CUSTOM_DOMAIN || ""; // E.g., cdn.domain.com

      await r2Client.send(
        new PutObjectCommand({
          Bucket: bucketName,
          Key: uniqueFilename,
          Body: buffer,
          ContentType: file.type || "image/jpeg",
        })
      );

      // Trả về link CDN hoặc link R2 công khai
      const imageUrl = customDomain
        ? `https://${customDomain}/${uniqueFilename}`
        : `https://${process.env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com/${bucketName}/${uniqueFilename}`;

      return NextResponse.json({ success: true, url: imageUrl });
    }

    // --- CHẾ ĐỘ 2: Lưu cục bộ (Local Fallback) để chạy thử nghiệm ---
    console.warn("⚠️ Cloudflare R2 chưa được cấu hình. Sử dụng local upload fallback...");
    
    const uploadDir = path.join(process.cwd(), "public", "uploads");
    
    // Đảm bảo thư mục public/uploads tồn tại
    await fs.mkdir(uploadDir, { recursive: true });
    
    const filePath = path.join(uploadDir, uniqueFilename);
    await fs.writeFile(filePath, buffer);

    const imageUrl = `/uploads/${uniqueFilename}`;
    return NextResponse.json({ success: true, url: imageUrl });
  } catch (error: any) {
    console.error("Lỗi upload file:", error);
    return NextResponse.json(
      { success: false, error: error.message || "Đã xảy ra lỗi khi upload file." },
      { status: 500 }
    );
  }
}
