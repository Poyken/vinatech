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

async function checkMaterial() {
    try {
        await sql.connect(config);
        const materialCode = 'ECVT30-258';
        console.log(`Checking material details: ${materialCode}`);
        
        const result = await sql.query`SELECT MaterialCode, MaterialName FROM STB_MaterialMaster WHERE MaterialCode = ${materialCode}`;
        console.table(result.recordset);

        // Also search for the Part No from the label
        const partNo = 'WEC3R0506QG';
        console.log(`Searching for Part No: ${partNo}`);
        const result2 = await sql.query`SELECT MaterialCode, MaterialName FROM STB_MaterialMaster WHERE MaterialCode LIKE '%' + ${partNo} + '%' OR MaterialName LIKE '%' + ${partNo} + '%'`;
        console.table(result2.recordset);

    } catch (err) {
        console.error(err);
    } finally {
        await sql.close();
    }
}

checkMaterial();
