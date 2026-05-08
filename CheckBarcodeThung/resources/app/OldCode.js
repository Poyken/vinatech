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


$("#totalStamps").on("keyup", function (e) {
    // Chỉ xử lý khi người dùng nhấn phím Enter
    if (e.key === 'Enter') {
        const errors = validateNumber(e.target.value, 1, 5);

        if (errors.length > 0) {
            errors.forEach(error => {
                alert('⚠' + error);
            });
            $("#totalStamps").val('');
            $("#totalStamps").focus();
        } else {
            $("#totalSmall").focus();
            $("#totalStamps").prop("readonly", true);
            $("#totalSmall").prop("readonly", false);
        }
    }
});


$("#totalSmall").bind("keyup", function (e) {

    if (e.key === 'Enter') {
        const errors = validateNumber(e.target.value, 1, 5);

        if (errors.length > 0) {
            errors.forEach(error => {
                alert('⚠' + error);
            });
            $("#totalSmall").val('');
            $("#totalSmall").focus();
        } else {
            totalSmall = $("#totalSmall").val()
            $("#totalSmall").focus()
            $("#totalSmall").prop("readonly", true);
            $("li").removeClass("unsetBorder");
            var eleHTML = '';
            for (let index = 1; index <= totalSmall; index++) {
                eleHTML += ` <li>
                                    <p class ='tree-item_box'>

                                        <input type="text"  class="tree-input form-control tree-item_input" id='stamp-child-${index}'  placeholder="Số tem thùng trong ${index}" readonly>
                                        <input type="text"  class="tree-input form-control" id='item-child-${index}'  placeholder="Số túi bóng thùng trong ${index}" readonly>
                                    </p>
                                  
                                
                            </li>`

            }
            $("#tree-item").html(eleHTML)
            $("#stamp-child-1").focus();
            $("#stamp-child-1").prop("readonly", false);

            createEventTreeItem(totalSmall);
        }
    }
});


function createEventTreeItem(totalSmall) {

    for (let index = 1; index <= totalSmall; index++) {
        $(`#stamp-child-${index}`).bind("keyup", function (e) {

            if (e.key === 'Enter') {
                const errors = validateNumber(e.target.value, 0, 30);

                if (errors.length > 0) {
                    errors.forEach(error => {
                        alert('⚠' + error);
                    });
                    $(`#stamp-child-${index}`).val('');
                    $(`#stamp-child-${index}`).focus();
                } else {

                    $(`#stamp-child-${index}`).prop("readonly", true);
                    $(`#item-child-${index}`).prop("readonly", false);
                    $(`#item-child-${index}`).focus();

                }
            }
        });



    }



    for (let index = 1; index <= totalSmall; index++) {
        $(`#item-child-${index}`).bind("keyup", function (e) {

            if (e.key === 'Enter') {
                const errors = validateNumber(e.target.value, 0, 30);

                if (errors.length > 0) {
                    errors.forEach(error => {
                        alert('⚠' + error);
                    });
                    $(`#item-child-${index}`).val('');
                    $(`#item-child-${index}`).focus();
                } else {
                    let stampChildVale = $(`#stamp-child-${index}`).val();
                    let itemChildVale = $(`#item-child-${index}`).val();
                    $(`#item-child-${index}`).prop("readonly", true);
                    $(`#stamp-child-${index + 1}`).prop("readonly", false);
                    $(`#stamp-child-${index + 1}`).focus();
                    //  tạo data số túi bóng tương ứng với từng thùng
                    let data = {
                        small: index,
                        number_stamp: stampChildVale,
                        number_plastic: itemChildVale,
                    }
                    plasticOfSmall.push(data)
                    // console.log("data: ",plasticOfSmall)
                    if (index === parseInt(totalSmall)) {
                        // Số lượng tem thùng ngoài 
                        let numberStamps = $("#totalStamps").val();
                        // Số lượng tem thùng trong
                        let numberSmall = $("#totalSmall").val();
                        // số túi bóng tương ứng với từng thùng : plasticOfSmall

                        CreateLayoutBarCode(numberStamps, numberSmall, plasticOfSmall);
                    }
                }
            }
        });



    }
}





function CreateLayoutBarCode(numberStamps, numberSmall, plasticOfSmall) {
    var boxCarton = document.getElementById("box-carton")
    for (let index = 1; index <= parseInt(numberStamps); index++) {
        let html = `
                        <div class="infoCarton">
                            <div class="group-item">
                                <label for="partNoCarton" class="label-item">PartNo Thùng Ngoài Tem ${index}:
                                </label>
                                <input type="text" class="partNoCarton w-100 form-control" id="partNoCarton${index}" />
                            </div>
                
                            <div class="group-item">
                                <label for="lotNoCarton" class="label-item">Tem LotNo Thùng Ngoài Tem ${index}:
                                </label>
                                <input type="text" class="lotNoCarton w-100 form-control" id="lotNoCarton${index}"  />
                            </div>
                    
                            <div class="group-item">
                                <label for="qtyCarton" class="label-item">Tem Số Lượng Thùng Ngoài Tem ${index}:
                                </label>
                                <input type="number" class="w-100 form-control" id="qtyCarton${index}" min="0"  />
                            </div>
                         </div>
            
                        `
        boxCarton.innerHTML += html;
    }

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
                    let checkDaplicateLotNo = true;


                    // for (let h = 0; h < partNoList.length; h++) {
                    //     if (partNoList[h] === lotNoCartonItem) {
                    //         checkDaplicatePartNo = true;

                    //     }

                    // }

                    const inputsPartNo = document.querySelectorAll('input.partNoCarton');
                    const inputsLotNo = document.querySelectorAll('input.lotNoCarton');
                  
                    inputsPartNo.forEach(input => {
                        if (input.value === lotNoCartonItem) {
                                        checkDaplicatePartNo = true;
                                    }
                        });

                     if (checkDaplicatePartNo) {
                        alert("⚠ Mã LotNo đang nhập trùng với ParNo, vui lòng nhập lại")
                        $(`#lotNoCarton${index}`).val('');
                        $(`#lotNoCarton${index}`).focus();
                        return false;
                    }     

                    
                //    if(inputsLotNo[0]===''){
                //         $(`#qtyCarton${index}`).focus();
                //         return false;
                //    }
                   
                //     inputsLotNo.forEach(input => {
                //         if (input.value !== lotNoCartonItem) {
                //                         checkDaplicateLotNo = false;
                //                     }
                //         });

                   
                //     if (!checkDaplicateLotNo) {
                //         alert("⚠ Các mã lotNo đang không trùng nhau, vui lòng nhập lại")
                //         $(`#lotNoCarton${index}`).val('');
                //         $(`#lotNoCarton${index}`).focus();
                //         return false;
                //     } 
                     $(`#qtyCarton${index}`).focus();
                   
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

                 

                            let checkDaplicatePartNo = false;
                             const inputsPartNo = document.querySelectorAll('input.partNoCarton');
                            
                            inputsPartNo.forEach(input => {if (input.value === partNoSmallItem) {
                                                                            checkDaplicatePartNo = true;
                                                                }
                                                            });
                            
                            
                                                            
                              if (checkDaplicatePartNo) {
                                    $(`#lotNoSmall${index}_${m}`).focus();
                                    
                                    return false;
                                }else{
                                    alert("⚠ Mã PartNo phải trùng với thùng ngoài")
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
                            //  nếu người dùng bắn nhầm lotno hoặc parnot
                            let lotNoSmallItem = $(`#lotNoSmall${index}_${m}`).val();
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



                            let checkDaplicatePartNo = false;
                            let checkDaplicateLotNo = false;
                            const inputsPartNo = document.querySelectorAll('input.partNoCarton');
                            const inputsLotNo = document.querySelectorAll('input.lotNoCarton');
                           
                            inputsPartNo.forEach(input => {
                                if (input.value === lotNoSmallItem) {
                                                checkDaplicatePartNo = true;
                                    }
                                });

                            inputsLotNo.forEach(input => {
                                if (input.value === lotNoSmallItem) {
                                                checkDaplicateLotNo = true;
                                    }
                                });
                                // console.log('check giatri',checkDaplicateLotNo)

                            if (checkDaplicatePartNo) {
                                alert("⚠ Mã LotNo đang nhập trùng với ParNo, vui lòng nhập lại")
                                $(`#lotNoSmall${index}_${m}`).val('');
                                $(`#lotNoSmall${index}_${m}`).focus();
                                return false;
                            } 
                            if (checkDaplicateLotNo) {
                                $(`#qtySmall${index}_${m}`).focus();
                            } else{
                                alert("⚠ Các mã lotNo đang không trùng nhau, vui lòng nhập lại")
                                $(`#lotNoSmall${index}_${m}`).val('');
                                $(`#lotNoSmall${index}_${m}`).focus();
                                return false;
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
                                        callElectrodeWasteSubmitProc(numberStamps, numberSmall, plasticOfSmall)
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
                            let partNoPlastic = $(`#partNoPlastic${index}_${m}`).val()
                            // $(`#partNoPlastic${index}_${m}`).prop("readonly", true);
                            // $(`#lotNoPlastic${index}_${m}`).prop("readonly", false);
                            let checkDaplicatePartNo = false;
                             const inputsPartNo = document.querySelectorAll('input.partNoCarton');
                            
                            inputsPartNo.forEach(input => {if (input.value === partNoPlastic) {
                                                                            checkDaplicatePartNo = true;
                                                                }
                                                            });
                            
                            
                            
                              if (checkDaplicatePartNo) {
                                    $(`#lotNoPlastic${index}_${m}`).focus();
                                } else{
                                    alert("⚠ Mã PartNo phải trùng với thùng ngoài")
                                    $(`#partNoPlastic${index}_${m}`).val('');
                                    $(`#partNoPlastic${index}_${m}`).focus();
                                    return false;
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


                            //  nếu người dùng bắn nhầm lotno hoặc parnot
                            let lotNoSmallItem = $(`#lotNoPlastic${index}_${m}`).val();
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

                            let checkDaplicatePartNo = false;
                            let checkDaplicateLotNo = false;
                            const inputsPartNo = document.querySelectorAll('input.partNoCarton');
                            const inputsLotNo = document.querySelectorAll('input.lotNoCarton');
                           
                            inputsPartNo.forEach(input => {
                                if (input.value === lotNoSmallItem) {
                                                checkDaplicatePartNo = true;
                                    }
                                });

                            inputsLotNo.forEach(input => {
                                if (input.value === lotNoSmallItem) {
                                                checkDaplicateLotNo = true;
                                    }
                                });
                                console.log('check giatri',checkDaplicateLotNo)

                            if (checkDaplicatePartNo) {
                                alert("⚠ Mã LotNo đang nhập trùng với ParNo, vui lòng nhập lại")
                                            $(`#lotNoPlastic${index}_${m}`).val('');
                                            $(`#lotNoPlastic${index}_${m}`).focus();
                                return false;
                            } 
                            if (checkDaplicateLotNo) {
                               $(`#qtyPlastic${index}_${m}`).focus();
                            } else{
                                 alert("⚠ Các mã lotNo đang không trùng nhau, vui lòng nhập lại")
                                $(`#lotNoPlastic${index}_${m}`).val('');
                                $(`#lotNoPlastic${index}_${m}`).focus();
                                return false;
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
                                    sumQtySmall += parseInt($(`#qtySmall${index}_${z + 1}`).val())

                                }




                                for (let z = 0; z < parseInt(plasticOfSmall[index - 1].number_plastic); z++) {
                                    sumQtyPlastic += parseInt($(`#qtyPlastic${index}_${z + 1}`).val())

                                }

                                // console.log('ceck: ',sumQtySmall)
                                // console.log('ceck: ',sumQtyPlastic)



                                if (parseInt(sumQtySmall) === parseInt(sumQtyPlastic)) {
                                    if (index === parseInt(numberSmall)) {
                                        console.log("ok, call api")

                                        callElectrodeWasteSubmitProc(numberStamps, numberSmall, plasticOfSmall)


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
    for (let n = 1; n <= parseInt(numberStamps); n++) {
        sumQtyCarton += parseInt($(`#qtyCarton${n}`).val());


    }


    for (let e = 1; e <= parseInt(numberSmall); e++) {
        for (let z = 0; z < parseInt(plasticOfSmall[e - 1].number_stamp); z++) {
            sumQtySmall += parseInt($(`#qtySmall${e}_${z + 1}`).val())

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


                for (let index = 1; index <= numberStamps; index++) {
                    dataSubmit.push(
                        {
                            part_no: $(`#partNoCarton${index}`).val(),
                            lot_no: $(`#lotNoCarton${index}`).val(),
                            quantity: $(`#qtyCarton${index}`).val(),
                            remark: $(`#remark`).val(),
                            level: 1,
                        }
                    )
                }

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
    let numberStamps = $("#totalStamps").val();
                        // Số lượng tem thùng trong
    let numberSmall = $("#totalSmall").val();
    callElectrodeWasteSubmitProc(numberStamps,numberSmall,plasticOfSmall);
})
