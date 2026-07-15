import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import * as schema from "./schema";
import * as dotenv from "dotenv";

// Nạp các biến môi trường từ .env.local
dotenv.config({ path: ".env.local" });

const connectionString =
  process.env.DATABASE_URL ||
  "postgres://postgres:postgres_local_pw@localhost:5432/vinatech_ecommerce";

function getSafeDatabaseUrl(u: string): string {
  try {
    new URL(u);
    return u;
  } catch {
    const match = u.match(/^(postgres(?:ql)?:\/\/)([^:]+):(.*)@([^/]+)\/(.+)$/);
    if (match) {
      const [_, protocol, username, password, hostAndPort, dbName] = match;
      const encodedPassword = encodeURIComponent(password);
      return `${protocol}${username}:${encodedPassword}@${hostAndPort}/${dbName}`;
    }
    return u;
  }
}

const client = postgres(getSafeDatabaseUrl(connectionString), { max: 1 });
const db = drizzle(client, { schema });

async function main() {
  console.log("⏳ Đang bắt đầu chèn dữ liệu mẫu (Seeding data)...");

  try {
    // 1. Chèn Danh mục (Categories)
    const insertedCategories = await db
      .insert(schema.categories)
      .values([
        { name: "Laptops", slug: "laptops" },
        { name: "Điện thoại", slug: "smartphones" },
        { name: "Phụ kiện", slug: "accessories" },
      ])
      .onConflictDoNothing()
      .returning();

    console.log(`✓ Đã chèn ${insertedCategories.length} danh mục.`);

    // Lấy ID danh mục (nếu đã có sẵn hoặc mới chèn)
    const dbCategories = await db.select().from(schema.categories);
    const laptopCat = dbCategories.find((c) => c.slug === "laptops");
    const phoneCat = dbCategories.find((c) => c.slug === "smartphones");
    const accCat = dbCategories.find((c) => c.slug === "accessories");

    if (!laptopCat || !phoneCat || !accCat) {
      throw new Error("Không thể truy vấn danh mục sau khi chèn.");
    }

    // 2. Chèn Sản phẩm (Products)
    const insertedProducts = await db
      .insert(schema.products)
      .values([
        {
          categoryId: laptopCat.id,
          name: "ASUS ROG Strix G16 (2026)",
          slug: "asus-rog-strix-g16-2026",
          description: "Laptop gaming hiệu năng cực khủng với CPU Intel Core i9 Gen 14, RTX 4070, màn hình 240Hz siêu mượt.",
          price: "34990000.00",
          stock: 10,
          isActive: true,
        },
        {
          categoryId: laptopCat.id,
          name: "MacBook Pro M4 (14-inch)",
          slug: "macbook-pro-m4-14-inch",
          description: "Màn hình Liquid Retina XDR sắc nét, chip Apple M4 siêu mạnh mẽ cho mọi tác vụ lập trình và xử lý đồ họa.",
          price: "39990000.00",
          stock: 8,
          isActive: true,
        },
        {
          categoryId: phoneCat.id,
          name: "iPhone 17 Pro Max",
          slug: "iphone-17-pro-max",
          description: "Thiết kế titan sang trọng, cụm camera zoom quang học 10x, cấu hình siêu khủng với chip A19 Bionic.",
          price: "35990000.00",
          stock: 15,
          isActive: true,
        },
        {
          categoryId: phoneCat.id,
          name: "Samsung Galaxy S26 Ultra",
          slug: "samsung-galaxy-s26-ultra",
          description: "Màn hình Dynamic AMOLED 2X sắc nét, bút S-Pen thông minh, cụm camera cảm biến 200MP tối ưu AI.",
          price: "31990000.00",
          stock: 12,
          isActive: true,
        },
        {
          categoryId: accCat.id,
          name: "Bàn phím cơ Keychron K2 Pro",
          slug: "keychron-k2-pro",
          description: "Bàn phím cơ không dây layout 75%, hỗ trợ QMK/VIA để tùy chỉnh phím, switch gõ siêu êm ái.",
          price: "2490000.00",
          stock: 30,
          isActive: true,
        },
        {
          categoryId: accCat.id,
          name: "Chuột không dây Logitech MX Master 3S",
          slug: "logitech-mx-master-3s",
          description: "Thiết kế công thái học đỉnh cao, cuộn MagSpeed siêu nhanh, mắt đọc 8K DPI sử dụng được trên mọi bề mặt.",
          price: "2290000.00",
          stock: 25,
          isActive: true,
        },
      ])
      .onConflictDoNothing()
      .returning();

    console.log(`✓ Đã chèn ${insertedProducts.length} sản phẩm mẫu.`);
    console.log("🎉 Hoàn tất chèn dữ liệu mẫu thành công!");
  } catch (error) {
    console.error("❌ Lỗi xảy ra khi seeding:", error);
  } finally {
    await client.end();
  }
}

main();
