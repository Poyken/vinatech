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

async function searchSPs() {
    try {
        await sql.connect(config);
        console.log(`--- SEARCHING FOR PROCEDURES ---`);
        
        const result = await sql.query`SELECT name FROM sys.procedures WHERE name LIKE '%FinishGood%' OR name LIKE '%ExportWarehouse%' OR name LIKE '%HN551%' OR name LIKE '%HN866%'`;
        
        console.table(result.recordset);
        
    } catch (err) {
        console.error('❌ LỖI KẾT NỐI:', err.message);
    } finally {
        await sql.close();
    }
}

searchSPs();
