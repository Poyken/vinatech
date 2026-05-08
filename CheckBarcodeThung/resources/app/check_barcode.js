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

async function checkBarcode() {
    try {
        await sql.connect(config);
        const barcode = 'VVQM223R050602';
        console.log(`Checking barcode details: ${barcode}`);
        
        const result = await sql.query`SELECT Barcode, MaterialCode, ProdQty FROM STB_SetInfo WHERE Barcode = ${barcode}`;
        console.log('STB_SetInfo Result:');
        console.table(result.recordset);

    } catch (err) {
        console.error(err);
    } finally {
        await sql.close();
    }
}

checkBarcode();
