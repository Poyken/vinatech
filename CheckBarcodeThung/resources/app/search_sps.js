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
        console.log(`--- SEARCHING FOR PROCEDURES RELATED TO HN544 ---`);
        
        const result = await sql.query`SELECT name FROM sys.procedures WHERE name LIKE '%HN544%' OR name LIKE '%GopTui%' OR name LIKE '%BoxID%' OR name LIKE '%PackingTime%'`;
        
        console.table(result.recordset);
        
    } catch (err) {
        console.error('❌ LỖI KẾT NỐI:', err.message);
    } finally {
        await sql.close();
    }
}

searchSPs();
