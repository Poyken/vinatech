const sql = require('mssql');

const config = {
    user: "vinaadmin",
    password: "vina1234%6&8",
    server: "dbserver.hycap.co.kr",
    port: 5398,
    database: "SmartFactoryV2",
    options: {
        encrypt: false,
    },
};

async function verifyFix() {
    try {
        await sql.connect(config);
        const barcode = 'VVQM223R050602';
        console.log(`--- ĐANG KIỂM TRA TIÊU CHUẨN CHO LOT: ${barcode} ---`);
        
        const result = await sql.query`EXEC usp_Vvt_TieuChuanPacking_Vvt @pBarCode = ${barcode}`;
        
        if (result.recordset.length > 0) {
            const data = result.recordset[0];
            console.log('KẾT QUẢ TỪ DATABASE:');
            console.log('------------------------------------------');
            console.log(`Model Code   : ${data.modelcode}`);
            console.log(`Thùng Ngoài  : ${data.thungNgoai} (Nếu là 500 thì đã OK)`);
            console.log(`Thùng Trong  : ${data.thungtrong}`);
            console.log(`Số túi bóng  : ${data.sotuibong}`);
            console.log('------------------------------------------');
            
            if (data.thungNgoai === 500) {
                console.log('✅ CHÚC MỪNG: Database đã cập nhật thành công số lượng 500!');
            } else {
                console.log(`❌ CẢNH BÁO: Số lượng vẫn đang là ${data.thungNgoai}. Hãy kiểm tra lại lệnh ALTER SP.`);
            }
        } else {
            console.log('❌ LỖI: Không tìm thấy thông tin cho mã Lot này.');
        }
        
    } catch (err) {
        console.error('❌ LỖI KẾT NỐI:', err.message);
    } finally {
        await sql.close();
    }
}

verifyFix();
