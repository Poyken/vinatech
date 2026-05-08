// window.onload = function (e) {
    
//     document.getElementById("partNoCarton").focus();
   
// };

// const { Alert } = require("bootstrap");
// // -------------------------------------------------------------------------------
// var sql = require("mssql");
// // Database Configuration
// var config = {
//     user: "vinaadmin",
//     password: "vina1234%6&8",
//     server: "dbserver.hycap.co.kr",
//     port: 5398,
//     database: "SmartFactoryV2",
//     options: {
//         encrypt: false,
//     },
// };

// //database remote issue
// const SmartFactoryV2 = ""; //"[dbserver.hycap.co.kr,5398].SmartFactoryV2.dbo.";
// const SmartFramework = "SmartFramework.dbo.";
// const SmartFactoryIncubator = "SmartFactoryIncubator.dbo.";
// //

var dataSet = {};
var qtyCreatePlastic = 0;

var dataArray = [];

var sothung =0
// // --------------------------------------------------------------------------------

// function showSmall(qtySmall, qtyPlastic) {
//     //  số lượng túi chia đều cho các box
//     var qtyPlasticPerSmall = qtyPlastic / qtySmall;
   
//     let smallCartonItem = document.getElementById("info");
//     let count=1;
//     for (let index = 1; index <= qtySmall; index++) {
//         const smallHTML = `  
//                             <div class="box">
//                                 <div class="box-small">
//                                     <div class="group-item">
//                                         <label for="lotNoSmall${index}" class="label-item">LotNo thùng trong ${index}:</label>
//                                         <input type="text" class="w-100 form-control" id="lotNoSmall${index}" />
//                                     </div>

//                                     <div class="group-item">
//                                         <label for="qtySmall${index}" class="label-item">Số lượng thùng trong ${index}:</label>
//                                         <input type="text" class="w-100 form-control" id="qtySmall${index}" />
//                                     </div>
//                                 </div>
//                                 <div class="box-plastic" id="box-plastic${index}">
                                
//                                 </div>
//                             </div>
                            
//                             `;

//         smallCartonItem.innerHTML += smallHTML;
//         let plasticItem = document.getElementById(`box-plastic${index}`);
//         for (let i = 1; i <= qtyPlasticPerSmall; i++) {
//             const plasticHtml = `
//                                 <div class="plastic-item">
//                                     <div class="item">
//                                         <label for="lotNoPlastic${count}" class="label-item">LotNo túi bóng ${i}:</label>
//                                         <input type="text" class="w-100 form-control" id="lotNoPlastic${count}"  />
//                                     </div>
//                                     <div class="item">
//                                         <label for="qtyPlastic${count}" class="label-item">Số lượng túi bóng  ${i}:</label>
//                                         <input type="text" class="w-100 form-control" id="qtyPlastic${count}"  />
//                                     </div>
//                                 </div>
//                             `;
//             plasticItem.innerHTML += plasticHtml;
//             count += 1;
//         }
//     }

//     for (let index = 1; index <= qtySmall; index++) {
//         $(`#lotNoSmall${index}`).bind("keyup", function (e) {
//             sessionStorage.isCell = 1;

//             var lotNoSmall_Val = document.getElementById(`lotNoSmall${index}`).value;

           
//             if (e.keyCode == "13" && lotNoSmall_Val === "") {
//                 alert(`⚠ LotNo thùng trong ${index} không được để trống !`);
//             }
//             if (e.keyCode == "13" && lotNoSmall_Val !== "") {
//                 if (
//                     lotNoSmall_Val.toUpperCase() ===
//                     document.getElementById("lotNoCarton").value.toUpperCase()
//                 ) {
//                     // document.getElementById(`lotNoSmall${index}`).readOnly = true;
//                     // document.getElementById(`qtySmall${index}`).readOnly = false;
//                     document.getElementById(`qtySmall${index}`).focus();
//                 } else {
//                     alert(`⚠Mã LotNo thùng trong ${index} không trùng với LotNo thùng ngoài, nhập lại !`);
//                     document.getElementById(`lotNoSmall${index}`).value = "";
//                     document.getElementById(`lotNoSmall${index}`).focus();
//                 }
//             }
//             event.preventDefault();
//             return true;
//         });

//         $(`#qtySmall${index}`).bind("keyup", function (e) {
//             sessionStorage.isCell = 1;
//             var qtySmall_Val = document.getElementById(`qtySmall${index}`).value;

//             if (e.keyCode == "13" && qtySmall_Val <= 0) {
//                 alert(`⚠ Số lượng thùng trong ${index} không được để trống !`);
//             }
//             if (e.keyCode == "13" && qtySmall_Val > 0) {
//                 if (parseInt(qtySmall_Val) !== dataSet.thungtrong) {
//                     alert(`⚠ Số lượng thùng trong ${index} phải là: ${dataSet.thungtrong} 
//                                             Vui lòng nhập lại`);
//                     document.getElementById(`qtySmall${index}`).value = "";
//                     document.getElementById(`qtySmall${index}`).focus();
//                 } else {
//                     if (index < qtySmall) {
                     
//                         // document.getElementById(`qtySmall${index}`).readOnly = true;
//                         // document.getElementById(`lotNoSmall${index + 1}`).readOnly = false;
//                         document.getElementById(`lotNoSmall${index + 1}`).focus();
//                     } else {
//                         var sumQtySmall = 0;
//                         for (let index = 1; index <= qtySmall; index++) {
//                             sumQtySmall += parseInt(
//                                 document.getElementById(`qtySmall${index}`).value
//                             );
//                         }

//                         if (
//                             parseInt(sumQtySmall) ===
//                             parseInt(document.getElementById("qtyCarton").value)
//                         ) {
                           
//                             //  data thung trong push vao csdl

//                             for (let index = 1; index <= qtySmall; index++) {
//                                 let dataSmall = {
//                                     part_no: $("#partNoCarton").val(),
//                                     lot_no: $(`#lotNoSmall${index}`).val(),
//                                     quantity: $(`#qtySmall${index}`).val(),
//                                     remark : $(`#remark`).val(),
//                                     level: 2,
//                                 };
//                                 dataArray.push(dataSmall);
//                             }

                           

//                             if (qtyPlastic > 0) {
//                                 // showPlastic(qtyCreatePlastic);
//                                 // showPlastic(2);

//                                 // document.getElementById(`qtySmall${index}`).readOnly = true;
//                                 // document.getElementById("lotNoPlastic1").readOnly = false;
//                                 document.getElementById("lotNoPlastic1").focus();
//                             }else{
//                                 // document.getElementById(`qtySmall${index}`).readOnly = true;
                              
//                                 callElectrodeWasteSubmitProc();
                                
//                             }
//                         } else {
//                             alert(
//                                 " ⚠ Tổng số lượng các thùng trong không bằng số lượng thùng ngoài vui lòng nhập lại "
//                             );
//                             document.getElementById(`qtySmall${index}`).value = "";
//                             document.getElementById(`qtySmall${index}`).focus();
//                         }
//                     }
//                 }
//             }
//             event.preventDefault();
//             return true;
//         });
//     }

//     for (let index = 1; index <= qtyPlastic; index++) {
//         $(`#lotNoPlastic${index}`).bind("keyup", function (e) {
//             sessionStorage.isCell = 1;

//             var lotNoPlastic_Val = document.getElementById(`lotNoPlastic${index}`).value;

//             if (e.keyCode == "13" && lotNoPlastic_Val === "") {
//                 alert(`⚠ Lot No túi bóng ${index} không được để trống !`);
//             }
//             if (e.keyCode == "13" && lotNoPlastic_Val !== "") {
//                 if (
//                     lotNoPlastic_Val.toUpperCase() ===  document.getElementById("lotNoCarton").value.toUpperCase()
//                 ) {
//                     // document.getElementById(`lotNoPlastic${index}`).readOnly = true;
//                     // document.getElementById(`qtyPlastic${index}`).readOnly = false;
//                     document.getElementById(`qtyPlastic${index}`).focus();
//                 } else {
//                     alert(`⚠ Lot No túi bóng ${index} không trùng với LotNo thùng lớn, nhập lại !`);
//                     document.getElementById(`lotNoPlastic${index}`).value = "";
//                     document.getElementById(`lotNoPlastic${index}`).focus();
//                 }
//             }
//             event.preventDefault();
//             return true;
//         });

//         $(`#qtyPlastic${index}`).bind("keyup", function (e) {
//             sessionStorage.isCell = 1;
//             var qtyPlastic_Val = document.getElementById(`qtyPlastic${index}`).value;
           
//             if (e.keyCode == "13" && qtyPlastic_Val <= 0) {
//                 alert(`⚠ Số lượng túi bóng ${index} không được để trống !`);
//             }
//             if (e.keyCode == "13" && qtyPlastic_Val > 0) {

//                 if (
//                     parseInt(qtyPlastic_Val) !== dataSet.tuibong
//                 ) {
//                     alert(`⚠ Số lượng túi bóng ${index} phải là : ${dataSet.tuibong} không được để trống !`);
//                     document.getElementById(`qtyPlastic${index}`).value = "";
//                     document.getElementById(`qtyPlastic${index}`).focus();
                   
//                 } else {
                    
//                     if (index < qtyPlastic) {
                    
//                         // document.getElementById(`qtyPlastic${index}`).readOnly = true;
//                         // document.getElementById(`lotNoPlastic${index + 1}`).readOnly = false;
//                         document.getElementById(`lotNoPlastic${index + 1}`).focus();
//                     } else {
                        
//                         var sumqtyPlastic = 0;
//                         for (let index = 1; index <= qtyPlastic; index++) {
//                             sumqtyPlastic += parseInt(
//                                 document.getElementById(`qtyPlastic${index}`).value
//                             );
//                         }

//                         if (
//                             parseInt(sumqtyPlastic) === parseInt(document.getElementById("qtyCarton").value)
//                         ) {
                         
//                             //  data thung trong push vao csdl

//                             for (let index = 1; index <= qtyPlastic; index++) {
//                                 let dataSmall = {
//                                     part_no: $("#partNoCarton").val(),
//                                     lot_no: $(`#lotNoPlastic${index}`).val(),
//                                     quantity: $(`#qtyPlastic${index}`).val(),
//                                     remark : $(`#remark`).val(),
//                                     level: 3,
//                                 };
//                                 dataArray.push(dataSmall);
//                             }
                     

//                             // document.getElementById(`qtyPlastic${index}`).readOnly = true;

                           
//                             callElectrodeWasteSubmitProc();
                            
                           
                           
//                         } else {
//                             alert(
//                                 " ⚠ Tổng số lượng các thùng trong không bằng số lượng thùng ngoài vui lòng nhập lại "
//                             );
//                             document.getElementById(`qtyPlastic${index}`).value = "";
//                             document.getElementById(`qtyPlastic${index}`).focus();
//                         }
//                     }
//                 }
//             }
//             event.preventDefault();
//             return true;
//         });
//     }


//     function callElectrodeWasteSubmitProc(){
//         if($(`#remark`).val()===''){
//             alert("⚠ Bạn chưa chọn người nhập barcode, vui lòng chọn !!!")
//             $(`#remark`).focus()
//             $("#remark").bind("change", function (e){
//                 if(dataArray.length>0){
//                     for (let index = 0; index < dataArray.length; index++){
//                         dataArray[index].remark= $(`#remark`).val()
//                     }
//                     callElectrodeWasteSubmitProc();

//                 }
                
//               })
//         }else{
//             if(dataArray.length>0){
//                 for (let index = 0; index < dataArray.length; index++) {
    
                   
//                     let procedureName =  SmartFactoryV2 + "usp_vietnam_checkbarcode_2624";
//                         //SmartFactoryV2 + "usp_DoCreateElectrodeWasteInfoNew_electron";
//                     let parameterStr =
//                         "pPartNo" +
//                         "|pLotNo" +
//                         "|pQuantity"+
//                         "|pRemark"+
//                         "|pLevel";
              
                 
//                     let parameterValue =
//                         dataArray[index].part_no +
//                         "|" +
//                         dataArray[index].lot_no +
//                         "|" +
//                         dataArray[index].quantity +
//                         "|" +
//                         dataArray[index].remark +
//                         "|" +
//                         dataArray[index].level
                    
//                     callProcedure(procedureName, parameterStr, parameterValue);   
                   
                        
//                 }
               
//             }
             
//         }
      
       
    
//     }
    
//     function callProcedure(procedureName, parameterStr, parameterValue) {
//         sql.connect(config, function (err) {
//           if (err) console.log(err);
      
//           var request = new sql.Request();
      
//           var pStr = parameterStr.split("|");
//           var pValue = parameterValue.split("|");
      
//           for (var i = 0; i < pStr.length; i++) {
//             var paramName = pStr[i];
//             var paramValue = pValue[i];
      
//             request.input(paramName, sql.NVarChar(100), paramValue);
//           }
      
//           request.execute(procedureName, function (err, recordsets, returnValue) 
//           {
//             alert('⚡ OK, GỬI DỮ LIỆU THÀNH CÔNG ');
//             window.location.reload();
          
//           });
          
//         //   requestClose(sql);
//         });
//       }

     
    
// }
// --------------------------------------------------------------------------------
$("#partNoCarton").bind("keyup", function (e) {
    sessionStorage.isCell = 0;
    var partNoCartonVal = document.getElementById("partNoCarton").value;
    if (e.keyCode == "13" ) {
        if (partNoCartonVal !== "") {
            document.getElementById("partNoCarton").readOnly = true;
            document.getElementById("lotNoCarton").readOnly = false;
            document.getElementById("lotNoCarton").focus();
        } else {
            alert1("⚠ Vui lòng điền mã PartNo thùng ngoài !");
           
        }
    }
    event.preventDefault();
    return true;
});

$("#lotNoCarton").bind("keyup", function (e) {
    // document.getElementById("lotNoCarton").readOnly = true;
    // document.getElementById("lotNoCarton").style.background="white";
    // sessionStorage.isCell = 1;
    var lotNoCartonVal = document.getElementById("lotNoCarton").value;
   
    if (e.keyCode == "13" && lotNoCartonVal === "") {
        alert("⚠ Vui lòng điền mã LotNo thùng ngoài  !");
    }
    if (e.keyCode == "13" && lotNoCartonVal !== "") {
     
        if($("#lotNoCarton").val()!==$("#partNoCarton").val()){
            (async function () {
                try {
                    var barcode = document.getElementById("lotNoCarton").value;
                    var qty = document.getElementById("qtyCarton").value;
                   
                           
                    await sql.connect(config, function (err) {
                        $('#loaderModal').modal('show');
                        if (err) {
                            
                            alert("Không thể kết nối tới cơ sở dữ liệu");
                            $('#loaderModal').modal('hide');
                            return false;
                        } else {
                            var procedureName = SmartFactoryV2 + "usp_Vvt_TieuChuanPacking_Vvt";
                            var request = new sql.Request();
    
                            request.input("pBarCode", sql.NVarChar(100), barcode);
                            
                            request.execute(procedureName, function (err, recordsets, returnValue) {
                                if (recordsets) recordsets = recordsets.recordsets;
                                if (recordsets) recordsets = recordsets[0];
                                if (recordsets) recordsets = recordsets[0];
                                if (
                                    recordsets &&
                                    procedureName.indexOf("usp_Vvt_TieuChuanPacking_Vvt") >= 0
                                ) {
                                    $('#loaderModal').modal('hide');
                                    dataSet = recordsets;
                                    console.log(dataSet)
                                    sothung = parseInt(dataSet.thungNgoai/dataSet.thungtrong)
                                    for (let index = 1; index <=sothung ; index++) {
                                        let data ={
                                                    small: index,
                                                    number_stamp: 1,
                                                    number_plastic: parseInt(dataSet.sotuibong/sothung)
                                                }
                                        plasticOfSmall.push(data)
                                    }
                               
                                    
                                    CreateLayoutBarCode(1,sothung,plasticOfSmall)
                                    document.getElementById("lotNoCarton").readOnly = true;
                                    document.getElementById("qtyCarton").readOnly = false;
                                    document.getElementById("qtyCarton").focus();
                                } else {
                                    
                                    alert("⚠ Mã LotNo thùng ngoài này chưa có tiêu chuẩn, Vui lòng báo với bộ phận IT !");
                                    $('#loaderModal').modal('hide');
                                    document.getElementById("lotNoCarton").value = "";
                                    document.getElementById("lotNoCarton").readOnly = false;
                                    document.getElementById("lotNoCarton").focus();
                                }
                            });
                        }
                    });
                } catch (err) {
                    // ... error checks
                }
            })();
    
            sql.on("error", (err) => {
                // ... error handler
            });     
        }else{
            alert("⚠ Mã LotNo không được trùng với PartNo vui lòng nhập lại !");
            document.getElementById("lotNoCarton").value = "";
            // document.getElementById("lotNoCarton").readOnly = false;
            document.getElementById("lotNoCarton").focus();
        }

        
    }
    event.preventDefault();
    return true;
});

$("#qtyCarton").bind("keyup", function (e) {
    sessionStorage.isCell = 1;
    var qtyCartonVal = document.getElementById("qtyCarton").value;
  
    if (e.keyCode == "13" && qtyCartonVal <= 0) {
        alert("⚠ Số lượng thùng ngoài không được để trống và phải lớn hơn 0!");
    }
    if (e.keyCode == "13" && qtyCartonVal > 0) {
        var qty = document.getElementById("qtyCarton").value;
        if (dataSet.thungNgoai === parseInt(qty)) {
            //  data thung ngoai push vao csdl
            let dataCarton = {
                part_no: $("#partNoCarton").val(),
                lot_no: $("#lotNoCarton").val(),
                quantity: $("#qtyCarton").val(),
                remark : $(`#remark`).val(),
                level: 1,
            };

            dataArray.push(dataCarton);
           
            // ---------------
            // document.getElementById("qtyCarton").readOnly = true;
            // so luong thung trong can tao ra
            let qtySmall = dataSet.thungNgoai / dataSet.thungtrong;
            let qtyPlastic = dataSet.sotuibong;
            if (qtySmall > 0) {
                // showSmall(qtySmall, qtyPlastic);
                // document.getElementById("lotNoSmall1").readOnly = false;
                document.getElementById("partNoSmall1_1").focus();

            }
        } else {
            alert(`⚠ Bạn đang điền sai số lượng thùng ngoài hoặc đây không phải là thùng ngoài 
                            Chú ý số lượng ở đây phải là : ${dataSet.thungNgoai} !`);
            document.getElementById("qtyCarton").value = "";
            document.getElementById("qtyCarton").readOnly = false;
            document.getElementById("qtyCarton").focus();
        }
    }
    event.preventDefault();
    return true;
});






// -----------------------------------------------------------------------


const { Alert } = require("bootstrap");
// -------------------------------------------------------------------------------
var sql = require("mssql");
// Database Configuration
var config = {
    user: "vinaadmin",
    password: "vina1234%6&8",
    server: "dbserver.hycap.co.kr",
    port: 5398,
    database: "SmartFactoryV2",
    options: {
        encrypt: false,
    },
};

//database remote issue
const SmartFactoryV2 = ""; //"[dbserver.hycap.co.kr,5398].SmartFactoryV2.dbo.";
const SmartFramework = "SmartFramework.dbo.";
const SmartFactoryIncubator = "SmartFactoryIncubator.dbo.";
//




// --------------------------------------------------------------------------------

var totalSmall = 0;
var plasticOfSmall = [];
var dataBarcode = [];
var dataSubmit = [];
var partNoList = []

function validateNumber(value, min = Number.MIN_SAFE_INTEGER, max = Number.MAX_SAFE_INTEGER) {
    value = getNumbersOnly(value)
    const errors = [];

    // Check if the trimmed value is empty
    if (value === '') {
        errors.push("Giá trị không được để trống");
        return errors;
    }

    // Use regex to check if the value is a valid number format
    const numberRegex = /^[+-]?(\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?$/;
    if (!numberRegex.test(value)) {
        errors.push("Giá trị không phải là số");
    } else {
        // Convert value to a number
        const numericValue = Number(value);

        // Check if numericValue is within the specified range
        if (numericValue < min) {
            errors.push(`Giá trị phải lớn hơn hoặc bằng ${min}`);
        }
        if (numericValue > max) {
            errors.push(`Giá trị phải nhỏ hơn hoặc bằng ${max}`);
        }
    }

    return errors;
}

function validateString(value) {
    const errors = [];

    // Check if the trimmed value is empty
    if (value === '') {
        errors.push("Giá trị không được để trống");
        return errors;
    }

    const regex = /^(?=.*[a-zA-Z])(?=.*\d)/;
    if (!regex.test(value)) {
        errors.push("Giá trị phải chứa ít nhất một chữ cái và một số");
    }
    return errors;
}











function CreateLayoutBarCode(numberStamps, numberSmall, plasticOfSmall) {
    // var boxCarton = document.getElementById("box-carton")
    // for (let index = 1; index <= parseInt(numberStamps); index++) {
    //     let html = `
    //                     <div class="infoCarton">
    //                         <div class="group-item">
    //                             <label for="partNoCarton" class="label-item">PartNo Thùng Ngoài Tem ${index}:
    //                             </label>
    //                             <input type="text" class="w-100 form-control" id="partNoCarton${index}" />
    //                         </div>
                
    //                         <div class="group-item">
    //                             <label for="lotNoCarton" class="label-item">Tem LotNo Thùng Ngoài Tem ${index}:
    //                             </label>
    //                             <input type="text" class="w-100 form-control" id="lotNoCarton${index}"  />
    //                         </div>
                    
    //                         <div class="group-item">
    //                             <label for="qtyCarton" class="label-item">Tem Số Lượng Thùng Ngoài Tem ${index}:
    //                             </label>
    //                             <input type="number" class="w-100 form-control" id="qtyCarton${index}" min="0"  />
    //                         </div>
    //                      </div>
            
    //                     `
    //     boxCarton.innerHTML += html;
    // }

    let smallCartonItem = document.getElementById("info");
    for (let index = 1; index <= parseInt(numberSmall); index++) {
        const smallHTML = `  
                                <div class="box">
                                    <div class="box-small"  id="box-small${index}" >
                                        
                                    </div>
                                    <div class="box-plastic" id="box-plastic${index}">
                                    
                                    </div>
                                </div>
                                
                                `;

        smallCartonItem.innerHTML += smallHTML;

        for (let key in plasticOfSmall) {
            if (plasticOfSmall.hasOwnProperty(key)) {
                if (index === plasticOfSmall[key].small) {
                    let smallItem = document.getElementById(`box-small${index}`);
                    for (let i = 1; i <= plasticOfSmall[key].number_stamp; i++) {
                        const smallHtml = `
                                                    <div class="box-small__item">
                                                        <div class="group-item">
                                                            <label for="partNoSmall${index}_${i}" class="label-item">PartNo tem thùng trong ${i}:</label>
                                                            <input type="text" class="w-100 form-control" id="partNoSmall${index}_${i}" />
                                                        </div>
                                                        <div class="group-item">
                                                            <label for="lotNoSmall${index}_${i}" class="label-item">LotNo tem thùng trong ${i}:</label>
                                                            <input type="text" class="w-100 form-control" id="lotNoSmall${index}_${i}" />
                                                        </div>
                                
                                                        <div class="group-item">
                                                            <label for="qtySmall${index}_${i}" class="label-item">Số lượng tem thùng trong ${i}:</label>
                                                            <input type="text" class="w-100 form-control" id="qtySmall${index}_${i}" />
                                                        </div>
                                                    </div>
                                            `;
                        smallItem.innerHTML += smallHtml;

                    }
                }

            }
        }


        for (let key in plasticOfSmall) {
            if (plasticOfSmall.hasOwnProperty(key)) {
                if (index === plasticOfSmall[key].small) {
                    let plasticItem = document.getElementById(`box-plastic${index}`);
                    for (let i = 1; i <= plasticOfSmall[key].number_plastic; i++) {
                        const plasticHtml = `
                                                <div class="plastic-item">
                                                    <div class="item">
                                                        <label for="partNoPlastic${index}_${i}" class="label-item">PartNo túi bóng ${i}:</label>
                                                        <input type="text" class="w-100 form-control" id="partNoPlastic${index}_${i}"  />
                                                    </div>
                                                    <div class="item">
                                                        <label for="lotNoPlastic${index}_${i}" class="label-item">LotNo túi bóng ${i}:</label>
                                                        <input type="text" class="w-100 form-control" id="lotNoPlastic${index}_${i}"  />
                                                    </div>
                                                    <div class="item">
                                                        <label for="qtyPlastic${index}_${i}" class="label-item">Số lượng túi bóng  ${i}:</label>
                                                        <input type="text" class="w-100 form-control" id="qtyPlastic${index}_${i}"  />
                                                    </div>
                                                </div>
                                            `;
                        plasticItem.innerHTML += plasticHtml;

                    }
                }
            }
        }

    }

    // $('#partNoCarton1').prop("readonly", false);
    $('#partNoCarton1').focus()


    //  Event của layout
    for (let index = 1; index <= parseInt(numberStamps); index++) {

        $(`#partNoCarton${index}`).bind("keyup", function (e) {

            if (e.key === 'Enter') {
                const errors = validateString(e.target.value);

                if (errors.length > 0) {
                    errors.forEach(error => {
                        alert('⚠' + error);
                    });
                    $(`#partNoCarton${index}`).val('');
                    $(`#partNoCarton${index}`).focus();
                } else {
                    let parNoCarton = $(`#partNoCarton${index}`).val();
                    partNoList.push(parNoCarton)
                    // $(`#partNoCarton${index}`).prop("readonly", true);
                    // $(`#lotNoCarton${index}`).prop("readonly", false);
                    $(`#lotNoCarton${index}`).focus();


                }



            }

        });


        $(`#lotNoCarton${index}`).bind("keyup", function (e) {

            if (e.key === 'Enter') {
                const errors = validateString(e.target.value);

                if (errors.length > 0) {
                    errors.forEach(error => {
                        alert('⚠' + error);
                    });
                    $(`#lotNoCarton${index}`).val('');
                    $(`#lotNoCarton${index}`).focus();
                } else {
                    let lotNoCartonItem = $(`#lotNoCarton${index}`).val();
                    let checkDaplicatePartNo = false;


                    for (let h = 0; h < partNoList.length; h++) {
                        if (partNoList[h] === lotNoCartonItem) {
                            checkDaplicatePartNo = true;

                        }

                    }


                    if (checkDaplicatePartNo) {
                        alert("⚠ Mã LotNo đang nhập trùng với ParNo, vui lòng nhập lại")
                        $(`#lotNoCarton${index}`).val('');
                        $(`#lotNoCarton${index}`).focus();
                    } else {
                        // $(`#lotNoCarton${index}`).prop("readonly", true);
                        // $(`#qtyCarton${index}`).prop("readonly", false);
                        $(`#qtyCarton${index}`).focus();
                    }
                }
            }


        });


        $(`#qtyCarton${index}`).bind("keyup", function (e) {
            if (e.key === 'Enter') {
                const errors = validateNumber(e.target.value);

                if (errors.length > 0) {
                    errors.forEach(error => {
                        alert('⚠' + error);
                    });
                    $(`#qtyCarton${index}`).val('');
                    $(`#qtyCarton${index}`).focus();
                } else {

                    dataBarcode.push({
                        part_no: $(`#partNoCarton${index}`).val(),
                        lot_no: $(`#lotNoCarton${index}`).val(),
                        quantity: $(`#qtyCarton${index}`).val(),
                        // remark : $(`#remark`).val(),
                        level: 1,
                    })


                    if (index === parseInt(numberStamps)) {

                        // $(`#qtyCarton${index}`).prop("readonly", true);
                        // $(`#partNoSmall1_1`).prop("readonly", false);
                        $(`#partNoSmall1_1`).focus();

                    } else {
                        // $(`#qtyCarton${index}`).prop("readonly", true);
                        // $(`#partNoCarton${index + 1}`).prop("readonly", false);
                        $(`#partNoCarton${index + 1}`).focus();
                    }

                }
            }
        });


    }



    for (let index = 1; index <= parseInt(numberSmall); index++) {



        if (plasticOfSmall[index - 1].number_stamp > 0) {
            for (let m = 1; m <= parseInt(plasticOfSmall[index - 1].number_stamp); m++) {
                $(`#partNoSmall${index}_${m}`).bind("keyup", function (e) {

                    if (e.key === 'Enter') {
                        const errors = validateString(e.target.value);

                        if (errors.length > 0) {
                            errors.forEach(error => {
                                alert('⚠' + error);
                            });
                            $(`#partNoSmall${index}_${m}`).val('');
                            $(`#partNoSmall${index}_${m}`).focus();
                        } else {

                            let partNoSmallItem = $(`#partNoSmall${index}_${m}`).val()
                            // partNoList.push(partNoSmallItem)
                            // $(`#partNoSmall${index}_${m}`).prop("readonly", true);
                            // $(`#lotNoSmall${index}_${m}`).prop("readonly", false);
                            
                            let valParNoCarton = $("#partNoCarton").val();
                            // if($(`#partNoSmall${index}_${m}`).val('');)

                            // console.log("check1231: ",partNoSmallItem,valParNoCarton)
                            if(valParNoCarton===partNoSmallItem){
                                  $(`#lotNoSmall${index}_${m}`).focus();
                            }else{
                                alert("⚠ Mã PartNo phải trùng nhau")
                                $(`#partNoSmall${index}_${m}`).val('');
                                $(`#partNoSmall${index}_${m}`).focus();
                            }
                          





                        }
                    }


                });

                $(`#lotNoSmall${index}_${m}`).bind("keyup", function (e) {

                    if (e.key === 'Enter') {
                        const errors = validateString(e.target.value);

                        if (errors.length > 0) {
                            errors.forEach(error => {
                                alert('⚠' + error);
                            });
                            $(`#lotNoSmall${index}_${m}`).val('');
                            $(`#lotNoSmall${index}_${m}`).focus();
                        } else {
                            // //  nếu người dùng bắn nhầm lotno hoặc parnot
                            // let lotNoSmallItem = $(`#lotNoSmall${index}_${m}`).val();
                            // let checkDalicatePartNo = false;
                            // for (let h = 0; h < partNoList.length; h++) {
                            //     if (partNoList[h] === lotNoSmallItem) {

                            //         checkDalicatePartNo = true;

                            //     }
                            // }

                            // if (checkDalicatePartNo) {
                            //     alert('⚠' + 'Mã LotNo trùng với ParNo');
                            //     $(`#lotNoSmall${index}_${m}`).val('');
                            //     $(`#lotNoSmall${index}_${m}`).focus();
                            // } else {
                            //     // $(`#lotNoSmall${index}_${m}`).prop("readonly", true);
                            //     // $(`#qtySmall${index}_${m}`).prop("readonly", false);
                            //     $(`#qtySmall${index}_${m}`).focus();
                            // }


                            let LotNoSmallItem = $(`#lotNoSmall${index}_${m}`).val();
                            // partNoList.push(partNoSmallItem)
                            // $(`#partNoSmall${index}_${m}`).prop("readonly", true);
                            // $(`#lotNoSmall${index}_${m}`).prop("readonly", false);
                            
                            let valLotNoCarton = $("#lotNoCarton").val();
                            // if($(`#partNoSmall${index}_${m}`).val('');)

                            // console.log("check1231: ",partNoSmallItem,valParNoCarton)
                            if(valLotNoCarton===LotNoSmallItem){
                                $(`#qtySmall${index}_${m}`).focus();
                            }else{
                                alert("⚠ Mã LotNo phải trùng nhau")
                                $(`#lotNoSmall${index}_${m}`).val('');
                                $(`#lotNoSmall${index}_${m}`).focus();
                            }


                        }
                    }


                });

                $(`#qtySmall${index}_${m}`).bind("keyup", function (e) {
                    if (e.key === 'Enter') {
                        const errors = validateNumber(e.target.value);

                        if (errors.length > 0) {
                            errors.forEach(error => {
                                alert('⚠' + error);
                            });
                            $(`#qtySmall${index}_${m}`).val('');
                            $(`#qtySmall${index}_${m}`).focus();
                        } else {
                            // check thùng cuối và tem cuối thùng trong
                            if (index === parseInt(numberSmall)) {


                                if (m === parseInt(plasticOfSmall[index - 1].number_stamp)) {
                                    if (plasticOfSmall[index - 1].number_plastic > 0) {

                                        // $(`#qtySmall${index}_${m}`).prop("readonly", true);
                                        // $(`#partNoPlastic${index}_1`).prop("readonly", false);
                                        $(`#partNoPlastic${index}_1`).focus();
                                    } else {
                                        // Call Store 
                                        console.log("gọi store ỏ đay")
                                        callElectrodeWasteSubmitProc(1,sothung,plasticOfSmall)
                                    }

                                } else {
                                    // $(`#qtySmall${index}_${m}`).prop("readonly", true);
                                    // $(`#partNoSmall${index}_${m+1}`).prop("readonly", false);
                                    $(`#partNoSmall${index}_${m + 1}`).focus();
                                }

                            } else {
                                // check nếu túi bóng thùng nhỏ là 0 thì chuyển sang thùng nhỏ tiếp, nếu có túi bóng thì sẽ nhảy focus sang túi bóng
                                //   nếu có 2 tem trên 1 thùng nhỏ thì phải chuyển sang tem tiếp theo
                                if (m === parseInt(plasticOfSmall[index - 1].number_stamp)) {
                                    if (plasticOfSmall[index - 1].number_plastic > 0) {

                                        //  sô túi bóng của thùng lơn hơn 0 thì sẽ nhảy vào túi bóng
                                        // $(`#qtySmall${index}_${m}`).prop("readonly", true);
                                        // $(`#partNoPlastic${index}_1`).prop("readonly", false);
                                        $(`#partNoPlastic${index}_1`).focus();
                                    } else {
                                        //  sô túi bóng của thùng < 0 thì sẽ nhảy vào thùng tiêp theo
                                        // $(`#qtySmall${index}_${m}`).prop("readonly", true);
                                        // $(`#partNoSmall${index+1}_1`).prop("readonly", false);
                                        $(`#partNoSmall${index + 1}_1`).focus();
                                    }

                                } else {
                                    // $(`#qtySmall${index}_${m}`).prop("readonly", true);
                                    // $(`#partNoSmall${index}_${m+1}`).prop("readonly", false);
                                    $(`#partNoSmall${index}_${m + 1}`).focus();
                                }


                            }



                            // if(index===parseInt(numberSmall)){
                            //     let sumQtyCarton=0 ;
                            //     let sumQtySmall=0 ;
                            //     for (let j = 0; j < dataBarcode.length; j++) {
                            //         if(dataBarcode[j].level===1){
                            //             sumQtyCarton+=parseInt(dataBarcode[j].quantity)
                            //         }

                            //     }
                            //     for (let h = 1; h <= parseInt(numberSmall); h++) {
                            //             sumQtySmall+=parseInt($(`#qtySmall${h}`).val())

                            //     }
                            //     if(parseInt(sumQtyCarton)===parseInt(sumQtySmall)){

                            //         if(plasticOfSmall[index-1].number_plastic >0){
                            //             $(`#qtySmall${index}`).prop("readonly", true);
                            //             $(`#lotNoPlastic${index}_1`).prop("readonly", false);
                            //             $(`#lotNoPlastic${index}_1`).focus();
                            //         }else{
                            //             // Call Store 
                            //             console.log("gọi store ỏ đay")
                            //             callElectrodeWasteSubmitProc(numberStamps, numberSmall, plasticOfSmall)
                            //         }

                            //     }else{

                            //         alert("⚠ Tổng số lượng thùng trong không bằng tổng số lượng thùng ngoài")

                            //         $(`#qtySmall${index}`).val('');
                            //         $(`#qtySmall${index}`).focus();
                            //     }
                            // }else{
                            //      // check nếu túi bóng thùng nhỏ là 0 thì chuyển sang thùng nhỏ tiếp, nếu có túi bóng thì sẽ nhảy focus sang túi bóng 
                            //     if(plasticOfSmall[index-1].number_plastic >0){
                            //         $(`#qtySmall${index}`).prop("readonly", true);
                            //         $(`#lotNoPlastic${index}_1`).prop("readonly", false);
                            //         $(`#lotNoPlastic${index}_1`).focus();
                            //     }else{
                            //         $(`#qtySmall${index}`).prop("readonly", true);
                            //         $(`#lotNoSmall${index+1}`).prop("readonly", false);
                            //         $(`#lotNoSmall${index+1}`).focus();
                            //     }
                            // }
                        }
                    }
                });
            }


        }




        if (plasticOfSmall[index - 1].number_plastic > 0) {
            for (let m = 1; m <= parseInt(plasticOfSmall[index - 1].number_plastic); m++) {
                $(`#partNoPlastic${index}_${m}`).bind("keyup", function (e) {

                    if (e.key === 'Enter') {
                        const errors = validateString(e.target.value);

                        if (errors.length > 0) {
                            errors.forEach(error => {
                                alert('⚠' + error);
                            });
                            $(`#partNoPlastic${index}_${m}`).val('');
                            $(`#partNoPlastic${index}_${m}`).focus();
                        } else {

                            // $(`#partNoPlastic${index}_${m}`).prop("readonly", true);
                            // $(`#lotNoPlastic${index}_${m}`).prop("readonly", false);
                            

                            let partNoPlasticItem =  $(`#partNoPlastic${index}_${m}`).val();
                          
                            
                            let valParNoCarton = $("#partNoCarton").val();
                            // if($(`#partNoSmall${index}_${m}`).val('');)

                            if(valParNoCarton===partNoPlasticItem){
                                $(`#lotNoPlastic${index}_${m}`).focus();
                            }else{
                                alert("⚠ Mã PartNo phải trùng nhau")
                                $(`#partNoPlastic${index}_${m}`).val('');
                                $(`#partNoPlastic${index}_${m}`).focus();
                            }

                        }
                    }


                });

                $(`#lotNoPlastic${index}_${m}`).bind("keyup", function (e) {

                    if (e.key === 'Enter') {
                        const errors = validateString(e.target.value);

                        if (errors.length > 0) {
                            errors.forEach(error => {
                                alert('⚠' + error);
                            });
                            $(`#lotNoPlastic${index}_${m}`).val('');
                            $(`#lotNoPlastic${index}_${m}`).focus();
                        } else {



                            // //  nếu người dùng bắn nhầm lotno hoặc parnot
                            // let lotNoSmallItem = $(`#lotNoPlastic${index}_${m}`).val();
                            // let checkDalicatePartNo = false;
                            // for (let h = 0; h < partNoList.length; h++) {
                            //     if (partNoList[h] === lotNoSmallItem) {

                            //         checkDalicatePartNo = true;

                            //     }
                            // }

                            // if (checkDalicatePartNo) {
                            //     alert('⚠' + 'Mã LotNo trùng với ParNo');
                            //     $(`#lotNoPlastic${index}_${m}`).val('');
                            //     $(`#lotNoPlastic${index}_${m}`).focus();
                            // } else {
                            //     // $(`#lotNoPlastic${index}_${m}`).prop("readonly", true);
                            //     // $(`#qtyPlastic${index}_${m}`).prop("readonly", false);
                            //     $(`#qtyPlastic${index}_${m}`).focus();


                                
                            // }
                            let lotNoPlasticItem = $(`#lotNoPlastic${index}_${m}`).val();
                            // partNoList.push(partNoSmallItem)
                            // $(`#partNoSmall${index}_${m}`).prop("readonly", true);
                            // $(`#lotNoSmall${index}_${m}`).prop("readonly", false);
                            
                            let valLotNoCarton = $("#lotNoCarton").val();
                            // if($(`#partNoSmall${index}_${m}`).val('');)

                            // console.log("check1231: ",partNoSmallItem,valParNoCarton)
                            if(valLotNoCarton===lotNoPlasticItem){
                                $(`#qtyPlastic${index}_${m}`).focus();
                            }else{
                                alert("⚠ Mã LotNo phải trùng nhau")
                                $(`#lotNoPlastic${index}_${m}`).val('');
                                $(`#lotNoPlastic${index}_${m}`).focus();
                            }

                        }
                    }


                });



                $(`#qtyPlastic${index}_${m}`).bind("keyup", function (e) {

                    if (e.key === 'Enter') {
                        const errors = validateNumber(e.target.value);

                        if (errors.length > 0) {
                            errors.forEach(error => {
                                alert('⚠' + error);
                            });
                            $(`#qtyPlastic${index}_${m}`).val('');
                            $(`#qtyPlastic${index}_${m}`).focus();
                        } else {



                            if (m === parseInt(plasticOfSmall[index - 1].number_plastic)) {
                                // check có phải túi bóng thùng cuối k
                                let sumQtySmall = 0;
                                let sumQtyPlastic = 0;

                                for (let z = 0; z < parseInt(plasticOfSmall[index - 1].number_stamp); z++) {
                                    sumQtySmall += parseInt(getNumbersOnly($(`#qtySmall${index}_${z + 1}`).val()))

                                }




                                for (let z = 0; z < parseInt(plasticOfSmall[index - 1].number_plastic); z++) {
                                    sumQtyPlastic += parseInt(getNumbersOnly($(`#qtyPlastic${index}_${z + 1}`).val()))

                                }

                                // console.log('ceck: ',sumQtySmall)
                                // console.log('ceck: ',sumQtyPlastic)



                                if (parseInt(sumQtySmall) === parseInt(sumQtyPlastic)) {
                                    if (index === parseInt(numberSmall)) {
                                        console.log("ok, call api")

                                        callElectrodeWasteSubmitProc(1,sothung,plasticOfSmall)


                                    } else {
                                        // $(`#qtyPlastic${index}_${m}`).prop("readonly", true);
                                        // $(`#partNoSmall${index+1}_1`).prop("readonly", false);
                                        $(`#partNoSmall${index + 1}_1`).focus();
                                    }
                                } else {
                                    alert("⚠ Tổng số lượng túi bóng không bằng số lượng thùng trong")
                                    $(`#qtyPlastic${index}_${m}`).val('');
                                    $(`#qtyPlastic${index}_${m}`).focus();
                                }

                            } else {
                                // $(`#qtyPlastic${index}_${m}`).prop("readonly", true);
                                // $(`#partNoPlastic${index}_${m+1}`).prop("readonly", false);
                                $(`#partNoPlastic${index}_${m + 1}`).focus();
                            }



                        }
                    }


                });
            }


        }




    }




}

function getNumbersOnly(str) {
    console.log(str);
  return str.replace(/\D/g, ''); // \D = mọi thứ KHÔNG phải là số
}

function callElectrodeWasteSubmitProc(numberStamps, numberSmall, plasticOfSmall) {
    // Lấy tất cả các input trên trang
    const inputs = document.querySelectorAll('input');

    // Tìm input đầu tiên chưa có giá trị
    let firstEmptyInput = null;
    inputs.forEach(input => {
        if (input.value.trim() === '' && firstEmptyInput === null) {
            firstEmptyInput = input;
        }
    });


    if (firstEmptyInput) {

        firstEmptyInput.focus();
        // alert("⚠ Điền thiếu thông tin, vui lòng bổ xung")
        return false;
    }

    // --------------------------------------------------------------------------------------
    let sumQtyCarton = 0;
    let sumQtySmall = 0;
    // for (let n = 1; n <= parseInt(numberStamps); n++) {
    //     sumQtyCarton += parseInt($(`#qtyCarton${n}`).val());


    // }
    sumQtyCarton=getNumbersOnly($("#qtyCarton").val());

    for (let e = 1; e <= parseInt(numberSmall); e++) {
        for (let z = 0; z < parseInt(plasticOfSmall[e - 1].number_stamp); z++) {
            sumQtySmall += parseInt(getNumbersOnly($(`#qtySmall${e}_${z + 1}`).val()))

        }

    }


    if (parseInt(sumQtyCarton) === parseInt(sumQtySmall)) {
        if ($(`#remark`).val() === '') {
            alert("⚠ Bạn chưa chọn người nhập barcode, vui lòng chọn !!!")
            $(`#remark`).focus()
            $("#remark").bind("change", function (e) {

                callElectrodeWasteSubmitProc(numberStamps, numberSmall, plasticOfSmall);


            })
        } else {
            if (numberStamps > 0) {

                    
                
                    dataSubmit.push(
                        {
                            part_no: $(`#partNoCarton`).val(),
                            lot_no: $(`#lotNoCarton`).val(),
                            quantity: $(`#qtyCarton`).val(),
                            remark: $(`#remark`).val(),
                            level: 1,
                        }
                    )
                

                if (parseInt(numberSmall) > 0) {
                    for (let index = 1; index <= numberSmall; index++) {
                        if (plasticOfSmall[index - 1].number_stamp > 0) {
                            for (let m = 1; m <= parseInt(plasticOfSmall[index - 1].number_stamp); m++) {
                                dataSubmit.push(
                                    {
                                        part_no: $(`#partNoSmall${index}_${m}`).val(),
                                        lot_no: $(`#lotNoSmall${index}_${m}`).val(),
                                        quantity: $(`#qtySmall${index}_${m}`).val(),
                                        remark: $(`#remark`).val(),
                                        level: 2,
                                    }
                                )
                            }
                        }


                        if (plasticOfSmall[index - 1].number_plastic > 0) {
                            for (let m = 1; m <= parseInt(plasticOfSmall[index - 1].number_plastic); m++) {
                                dataSubmit.push(
                                    {
                                        part_no: $(`#partNoPlastic${index}_${m}`).val(),
                                        lot_no: $(`#lotNoPlastic${index}_${m}`).val(),
                                        quantity: $(`#qtyPlastic${index}_${m}`).val(),
                                        remark: $(`#remark`).val(),
                                        level: 3,
                                    }
                                )
                            }
                        }



                    }
                }


                console.log("Data cuoi : ", dataSubmit)
                let checkError = false;

                for (let index = 0; index < dataSubmit.length; index++) {


                    let procedureName = SmartFactoryV2 + "usp_vietnam_checkbarcode_2624";
                    //SmartFactoryV2 + "usp_DoCreateElectrodeWasteInfoNew_electron";
                    let parameterStr =
                        "pPartNo" +
                        "|pLotNo" +
                        "|pQuantity" +
                        "|pRemark" +
                        "|pLevel";


                    let parameterValue =
                        dataSubmit[index].part_no +
                        "|" +
                        dataSubmit[index].lot_no +
                        "|" +
                        dataSubmit[index].quantity +
                        "|" +
                        dataSubmit[index].remark +
                        "|" +
                        dataSubmit[index].level



                    if (callProcedure(procedureName, parameterStr, parameterValue) === false) {
                        checkError = true;
                    }

                }

                if (checkError === false) {
                    alert('⚡ OK, GỬI DỮ LIỆU THÀNH CÔNG ');
                    // window.location.reload();
                } else {
                    alert("⚠ Có lỗi khi truyền Data liên hệ bộ phận IT")
                }

            }

        }

        console.log("so luong da bang nhau hehe")


    } else {

        alert("⚠ Tổng số lượng thùng trong không bằng tổng số lượng thùng ngoài")
        return false;

    }


    // -------------------------------------------------------------------------------------








}

function callProcedure(procedureName, parameterStr, parameterValue) {


    sql.connect(config, function (err) {
        if (err) console.log(err);

        var request = new sql.Request();

        var pStr = parameterStr.split("|");
        var pValue = parameterValue.split("|");

        for (var i = 0; i < pStr.length; i++) {
            var paramName = pStr[i];
            var paramValue = pValue[i];

            request.input(paramName, sql.NVarChar(100), paramValue);
        }

        request.execute(procedureName, function (err, recordsets, returnValue) {

            if (err) {

                return false;

            } else {
                return true;
            }


        });

        //   requestClose(sql);
    });


}



$("#submitData").bind("click", function (e){
    const inputs = document.querySelectorAll('input');

    // Tìm input đầu tiên chưa có giá trị
    let firstEmptyInput = null;
    inputs.forEach(input => {
        if (input.value.trim() === '' && firstEmptyInput === null) {
            firstEmptyInput = input;
        }
    });


    if (firstEmptyInput) {

        firstEmptyInput.focus();
        alert("⚠ Điền thiếu thông tin, vui lòng bổ xung")
        return false;
    }

    callElectrodeWasteSubmitProc(1,sothung,plasticOfSmall);
})

