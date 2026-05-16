const sql = require('mssql');
const fs = require('fs');

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

async function getSPContent() {
    try {
        await sql.connect(config);
        const spName = 'usp_Vietnam_GetBoxIDForLotNo_VVT';
        console.log(`--- SAVING CONTENT OF PROCEDURE: ${spName} ---`);
        
        const result = await sql.query`SELECT OBJECT_DEFINITION(OBJECT_ID(${spName})) as content`;
        
        if (result.recordset.length > 0) {
            fs.writeFileSync('sp_definition.sql', result.recordset[0].content);
            console.log('Saved to sp_definition.sql');
        } else {
            console.log('Not found');
        }
        
    } catch (err) {
        console.error('❌ LỖI:', err.message);
    } finally {
        await sql.close();
    }
}

getSPContent();
