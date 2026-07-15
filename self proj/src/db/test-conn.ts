import postgres from "postgres";
import * as dotenv from "dotenv";

dotenv.config({ path: ".env.local" });

const password = "Axpt4869????"; // Sẽ dùng mật khẩu thực tế
const projectRef = "fdanvptxlcbqbjutcacs";

const regions = [
  "ap-southeast-1", // Singapore (Phổ biến nhất ở VN)
  "ap-southeast-2", // Sydney
  "ap-northeast-1", // Tokyo
  "ap-northeast-2", // Seoul
  "ap-south-1",     // Mumbai
  "us-east-1",      // N. Virginia (Mặc định nếu chọn vùng Mỹ)
  "us-east-2",      // Ohio
  "us-west-1",      // N. California
  "us-west-2",      // Oregon
  "eu-central-1",   // Frankfurt
  "eu-west-1",      // Ireland
  "eu-west-2",      // London
];

async function scanRegions() {
  console.log("⏳ Bắt đầu quét tìm Region Supabase phù hợp...");
  
  for (const region of regions) {
    const host = `aws-0-${region}.pooler.supabase.com`;
    const url = `postgres://postgres.${projectRef}:${encodeURIComponent(password)}@${host}:6543/postgres`;
    
    console.log(`Checking region: ${region} (${host})...`);
    const sql = postgres(url, { prepare: false, connect_timeout: 3 });
    
    try {
      const result = await sql`SELECT 1 as ok;`;
      if (result && result[0].ok === 1) {
        console.log(`\n🎉 TÌM THẤY REGION CHÍNH XÁC: ${region}`);
        console.log(`URL kết nối chuẩn của bạn là:`);
        console.log(`postgres://postgres.${projectRef}:[MẬT_KHẨU_CỦA_BẠN]@${host}:6543/postgres`);
        await sql.end();
        return region;
      }
    } catch (err: any) {
      // Nếu lỗi là sai mật khẩu (invalid password) thì chứng tỏ đã tìm thấy đúng server (đúng region) nhưng mật khẩu sai!
      // Nếu lỗi là tenant not found thì có nghĩa là sai region.
      const msg = err.message || "";
      if (msg.includes("password authentication failed") || msg.includes("Authentication failed")) {
        console.log(`\n⚠️ REGION ĐÚNG LÀ ${region} (nhưng mật khẩu database của bạn trong .env.local bị sai!)`);
        await sql.end();
        return region;
      }
      console.log(`-> ${region} thất bại: ${msg.trim()}`);
    } finally {
      try {
        await sql.end();
      } catch {}
    }
  }
  
  console.log("\n❌ Không tìm thấy region nào phù hợp. Vui lòng kiểm tra lại projectRef hoặc mật khẩu.");
  return null;
}

scanRegions();
