import { NextRequest, NextResponse } from "next/server";
import { writeFile, mkdir } from "fs/promises";
import path from "path";

export async function POST(req: NextRequest) {
  try {
    const formData = await req.formData();
    const file = formData.get("file") as File;

    if (!file) {
      return NextResponse.json({ error: "Không tìm thấy tệp tải lên" }, { status: 400 });
    }

    const bytes = await file.arrayBuffer();
    const buffer = Buffer.from(bytes);

    // Ensure public/uploads directory exists
    const uploadDir = path.join(process.cwd(), "public", "uploads");
    await mkdir(uploadDir, { recursive: true });

    // Generate unique filename to avoid overrides
    const ext = path.extname(file.name) || ".jpg";
    const filename = `speaker_${Date.now()}${ext}`;
    const filePath = path.join(uploadDir, filename);

    // Write the binary data to public folder
    await writeFile(filePath, buffer);

    // Return the relative URL path
    return NextResponse.json({ url: `/uploads/${filename}` });
  } catch (error: any) {
    console.error("Upload error:", error);
    return NextResponse.json({ error: "Lỗi lưu trữ tệp tin" }, { status: 500 });
  }
}
