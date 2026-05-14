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

async function getSPDefinition() {
    try {
        await sql.connect(config);
        const spName = 'ExportWarehouseFinshGoodInventory_uid';
        console.log(`--- FETCHING DEFINITION FOR: ${spName} ---`);
        
        const result = await sql.query`SELECT OBJECT_DEFINITION(OBJECT_ID(${spName})) AS Definition`;
        
        if (result.recordset.length > 0 && result.recordset[0].Definition) {
            console.log(result.recordset[0].Definition);
        } else {
            console.log('❌ LỖI: Không tìm thấy định nghĩa cho SP này.');
        }
        
    } catch (err) {
        console.error('❌ LỖI KẾT NỐI:', err.message);
    } finally {
        await sql.close();
    }
}

getSPDefinition();
