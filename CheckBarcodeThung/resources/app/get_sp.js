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

async function getSP() {
    try {
        await sql.connect(config);
        const result = await sql.query`SELECT OBJECT_DEFINITION(OBJECT_ID('usp_Vvt_TieuChuanPacking_Vvt')) AS definition`;
        console.log(result.recordset[0].definition);
    } catch (err) {
        console.error(err);
    } finally {
        await sql.close();
    }
}

getSP();
