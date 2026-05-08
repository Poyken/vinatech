// function getTodayStr(ID, delimiter) {
//   var today = new Date();
//   var dd = String(today.getDate()).padStart(2, "0");
//   var mm = String(today.getMonth() + 1).padStart(2, "0"); //January is 0!
//   var yyyy = today.getFullYear();

//   today = yyyy + delimiter + mm + delimiter + dd;

//   document.getElementById(ID).value = today;
// }

// function initFormData() {
//   document.getElementById("LotPacking").value = "";
//   document.getElementById("LotPacking").focus();
//   // getTodayStr("jobDate", "-");
//   document.getElementById("routeCode").value = "";
//   document.getElementById("machineCode").value = "";
//   document.getElementById("currentCollectorClassCode").value = "";
//   document.getElementById("defectCode").value = "";
//   document.getElementById("defectWeight").value = "";
//   document.getElementById("remark").value = "";
//   document.getElementById("UnitW").value = "";  
// }

// function checkFormData() {
//   var LotPacking1 =
//     document.getElementById("LotPacking1").value == null
//       ? ""
//       : document.getElementById("LotPacking1").value;
//   var LotPacking2 =
//     document.getElementById("LotPacking2").value == null
//       ? ""
//       : document.getElementById("LotPacking2").value;
//   var LotPacking3 =
//     document.getElementById("LotPacking3").value == null
//       ? ""
//       : document.getElementById("LotPacking3").value;
  
//   var remark =
//     document.getElementById("remark").value == null
//       ? ""
//       : document.getElementById("remark").value;


  
//     if(!remark) {
//         alert('⚠ Vui lòng chọn lại tên của bạn ở NGƯỜI BẮN BARCODE mỗi 12 giờ / một lần!'); return;
//     }


//   if (
//     LotPacking1 == "" || LotPacking2 == "" || LotPacking3==""
//   ) {
//     alert("⚠ Mã   LOT   phải được điền vào !");
//     document.getElementById('LotPacking1').removeAttribute('readonly');
//   document.getElementById('LotPacking2').readOnly = true;
//   document.getElementById('LotPacking3').readOnly = true;

//   document.getElementById("LotPacking1").focus();
//     return false;
//   }
//   return true;
// }


// function readElectrodeWasteWeight(ID) {
//   var fs = require("fs");

//   fs.readFile("ew", "utf8", function (err, data) {
//     if (data && data != "") {
//       document.getElementById(ID).value = data;
//     }
//   });
// }

// function clearElectrodeWasteWeight() {
//   var fs = require("fs");

//   var defectWeight = document.getElementById("defectWeight").value;

//   fs.readFile("ew", "utf8", function (err, data) {
//     if (data == defectWeight) {
//       fs.writeFile("ew", "", "utf8", function (error) {
//         console.log("clear!");
//       });
//     }
//   });
// }

