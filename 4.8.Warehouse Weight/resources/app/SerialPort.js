const SerialPort = require("serialport");
var fs = require('fs');

function connectSerialPort(portName) 
{
  try{

  const port = new SerialPort(portName, {
    baudRate: 9600,
  });

  // serialport.list(/*(err, ports)*/).then(function (err, ports) {
  //   if (err && !ports) ports = err;

  //   ports.forEach(function (port) {
  //     console.log("Port: ", port);
  //   });
  // });  
  
  //alert('⚡ Đã kết nối cổng '+portName +'. \nĐang đợi dữ liệu gửi vào... ☺');
  
  return port;
  }
  catch{
    alert('⚠ ☹ Không kết nối được '+portName +'. \n\nVui lòng kiểm tra lại.');
    return null;
  }
}


String.prototype.replaceJoin = function (search, replacement) {
  var target = this;
  return target.split(search).join(replacement);
};


function getCurMonth(){
  var today = new Date();

  var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
  var yyyy = today.getFullYear();

  today =  yyyy+"/" + mm;
  return today;
}


function getCurdate(){
  var today = new Date();
  var dd = String(today.getDate()).padStart(2, '0');
  var hh = today.getHours();

  today =   dd+hh;
  return today;
}


function sendSerialData(port, data) {
  if(!port) return;
  port.write(data);
}


sessionStorage.comweightvalue='';
sessionStorage.pcsesvalue='';

sessionStorage.pcsesTime=new Date().toISOString();


Date.prototype.addMiliSeconds = function(sss) {
  this.setTime(this.getTime() + (sss));
  return this;
}


function getSerialData(port, ID, IdUnit,idpcs) {

  if(!port) return;

  var buffer = "";
  var buffer1 = "";
  var serialData = 0.0;

  console.log('bắt đầu chờ dữ liệu trên cổng: '+port.path);
    
  var firststr="";
  var bottomstr="";
  var yinyang=false;
  var lastval="";

  port.on("data", function (chunk) {
    
    if(buffer1 == firststr)
        buffer1 =""; //1111111111
    
    //console.log("chunk=", chunk);
    //buffer1 += bottomstr+chunk; //////222222

    buffer1 += chunk;

	
	  if(!buffer1) return;


    if(buffer1.toLowerCase().indexOf(' g')>0){ ///////22222
      firststr = buffer1.split(' g')[0]+' g';
      bottomstr = buffer1.split(' g')[1];
      //console.log("bottomstr=====", bottomstr);
      buffer1 = firststr;
      //console.log("buffer1=======", buffer1);      
    } else {
      return;
    }

    buffer = buffer1.toLowerCase();

/*
PCS:        102
Tare:           g
NET:    782.6   g
U/W:    7.6717  g
*/

    console.log("buffer=", buffer);
    //console.log("buffer=", buffer.replace(/[^0-9.]/g, ""));
    
    var answer = buffer.split(/\r?\n/);
    console.log("answer=", answer);


    for (i = 0; i < answer.length; i++) {
      var tmp = answer[i];
      console.log(tmp);
      
      if (tmp) tmp = tmp;
      else 
        continue;


      if (
        tmp &&
        tmp.indexOf("net: ") >= 0 &&
        tmp.lastIndexOf(" g") > tmp.indexOf("net: ")
      ) {
        //console.log("++++", tmp);
        var tmp2 = tmp.replaceJoin(" ", "").replace(/[^0-9.]/g, "");
        if (tmp2) {

          var obj1 = document.getElementById(ID);
          obj1.value = tmp2;

          //console.log("++90909090++", tmp);
          // answer = [];
          // answer.push(tmp);
          // buffer = "";
          //break;
        } 
          else 
            continue;
      } 
      

      if (
        tmp &&
        tmp.indexOf("u/w: ") >= 0 &&
        tmp.lastIndexOf(" g") > tmp.indexOf("u/w: ")
      ) {
        //console.log("++++", tmp);
        var tmp2 = tmp.replaceJoin(" ", "").replace(/[^0-9.]/g, "");
        if (tmp2) {

          var obj1 = document.getElementById(IdUnit);
          obj1.value = tmp2;

          //console.log("++90909090++", tmp);
          // answer = [];
          // answer.push(tmp);
          // buffer = "";
          // break;
        } 
          else 
            continue;
      }
      
      
      if (
        tmp &&
        tmp.indexOf("pcs: ") >= 0 
      ) {
        //console.log("++++", tmp);
        var tmp2 = tmp.replaceJoin(" ", "").replace(/[^0-9.]/g, "");
        if (tmp2) {

          var obj1 = document.getElementById(idpcs);
          obj1.value = tmp2;

          //console.log("++90909090++", tmp);
          // answer = [];
          // answer.push(tmp);
          // buffer = "";
          // break;
        }
          else 
            continue;
      }
    }

    
//document.getElementById("audioting").play();
    if(parseInt(sessionStorage.counter1)==0 ){

      if(document.getElementById(idpcs).value != sessionStorage.tuibong1){    //  50   100  
        document.getElementById("audioerro").play();
        document.getElementById("errorid0").innerHTML="Lần đầu của Lót cần cân đúng 100 con tụ (hoặc 50 nếu tiêu chuẩn túi bóng là 50)";
      }

    }
    else  if(parseInt(sessionStorage.counter1)==1 ){

      if(document.getElementById(idpcs).value != sessionStorage.tuibong1){        
        document.getElementById("audioerro").play();
        document.getElementById("errorid0").innerHTML="Lần thứ 2 của Lót cần cân đúng tiêu chuẩn túi bóng là " + sessionStorage.tuibong1 ;
      }
      //else sessionStorage.gramlan2 = document.getElementById(idpcs).value;    // cân nặng chứ ko phải pcs
    }
    else  if(parseInt(sessionStorage.counter1)==2 ){

      if(document.getElementById(idpcs).value >= sessionStorage.tuibong1){
        document.getElementById("audioerro").play();
        document.getElementById("errorid0").innerHTML="Lần thứ 3 của Lót cần cân thêm vỏ túi bóng + tiêu chuẩn túi bóng là " + sessionStorage.tuibong1 ;
      }
      else {
       // sessionStorage.covertuibong = document.getElementById(idpcs).value-sessionStorage.gramlan2;   // cân nặng chứ ko phải pcs
      }

    }



    if( document.getElementById(idpcs).value == sessionStorage.pcsesvalue )
    {
      if(new Date(sessionStorage.pcsesTime).addMiliSeconds(1000) < new Date()){
          if(document.getElementById(idpcs).value==100 && sessionStorage.pcsesvalue1 != sessionStorage.pcsesvalue)
          {
            //call INSESERT         errorid0
            document.getElementById("sumit").click();        
            sessionStorage.pcsesvalue1=sessionStorage.pcsesvalue;
            sessionStorage.pcsesTime  = new Date().toISOString();
          }
    }
    }
    else {
        sessionStorage.pcsesvalue = document.getElementById(idpcs).value;
        sessionStorage.pcsesTime  = new Date().toISOString();
    }
    //if(document.getElementById(idpcs))

  return;

    // console.log("answer=", answer);
    // buffer = answer.pop();
    // console.log("buffer=", buffer);

    // if (
    //   buffer &&
    //   buffer.indexOf("net") >= 0 &&
    //   buffer.indexOf(":") > buffer.indexOf("net") &&
    //   buffer.lastIndexOf(" g") > buffer.indexOf(":")
    // ) {
    //   answer = [];
    //   answer.push(buffer);
    // }



    //start process data
    if (
      answer.length > 0 &&
      (
        answer[0].indexOf("net") >= 0 || answer[0].indexOf("NET") >= 0
      ) 
      &&
      (
        answer[0].indexOf(":") > answer[0].indexOf("net") || answer[0].indexOf(":") > answer[0].indexOf("NET")
      ) 
      &&
      (
        answer[0].lastIndexOf(" g") > answer[0].indexOf(":") || answer[0].lastIndexOf(" G") > answer[0].indexOf(":")
      )
    ) {

      serialData = answer[0].replaceJoin(" ", "").replace(/[^0-9.]/g, "");
      console.log("serialData=", serialData);

      var obj1 = document.getElementById(ID);
      var obj2 = document.getElementById(IdUnit);

      console.log("obj1 :::::" + obj1.value);
      console.log("obj2 :::::" + obj2.value);
      //console.log("isEmpty(obj1.value) ::::: " + isEmpty(obj1.value));
      //console.log("isEmpty(obj2.value) ::::: " + isEmpty(obj2.value));

      if (!(obj1.value)) {
        obj1.value = serialData;
		    //sessionStorage.comweightvalue=serialData;
        //checkMaterialSpec(obj1.value, obj2.value);
      } 
      else if (!(obj2.value)){
        obj2.value = serialData;
        //checkMaterialSpec(obj1.value, obj2.value);
      }
      buffer = "";
    }


 
   
    // var newDest = __dirname.replaceJoin('\\','/') +'/log/'+getCurMonth();    
    // if (!fs.existsSync(newDest)) fs.mkdirSync(newDest,{recursive :true} );
    
    // var newlog = newDest +"/"+ getCurdate()+".log";
    // var content1 = new Date().toLocaleTimeString() +" "+ buffer + '\r\n';

    // fs.writeFile(newlog, content1,  {'flag':'a'}, err => {
    //   if (err) {
    //     console.error(err);
    //     return;
    //   }
    //   //file written successfully
    // })



    if(buffer.toLowerCase().indexOf(' g') != buffer.toLowerCase().lastIndexOf(' g')  ) {
      return;
    }


    

    //console.log('yinyang='+ (buffer.indexOf(',-')>0) );
    if(buffer && buffer.indexOf("ST,GS")>=0)
    if(buffer.toLowerCase().indexOf(" g") > 0 )
    //if(localStorage.replace1 && buffer.indexOf(localStorage.replace1)>=0 ||  
     //  localStorage.replace2 && buffer.indexOf(localStorage.replace2)>=0 || 
      // localStorage.replace3 && buffer.indexOf(localStorage.replace3)>=0)   
      {
        //serialData = buffer.replaceJoin(" ", "").replace(/[^0-9.]/g, "");
        yinyang=false;

        if(buffer.indexOf(',-')>0) yinyang=true;
        //console.log('yinyang12========='+yinyang);

        serialData = buffer.replaceJoin(" ", "").replace(/[^0-9.]/g, "");      
        //console.log('serialData231========='+serialData);

        if( !isFinite(parseFloat(serialData) ) ) {
          buffer="";
          //console.log('not isFinite serialData ------------------------------'+serialData);
          return;
        }
        
        //if(!confirmweight)
        if(parseFloat(serialData )>0 && !yinyang  ){         
			    //if(yinyang) return;
            lastval = serialData;
			      sessionStorage.comweightvalue=serialData;
            buffer="";
            //console.log('not yinyang and not <0.006 ---------------------------'+serialData);
            return;
        }

        // if(!yinyang){
        //   lastval = serialData;
        //   buffer="";
        //   return;
        // }
        
        if(!lastval) {
          buffer="";
          //console.log('last val --failed --------------------------'+lastval);
          return;
        }
  
        var obj1 = document.getElementById(ID); 
        var obj2 = document.getElementById(IdUnit);
  
        console.log("obj1 :::::" + obj1.value);
        //console.log("obj2 :::::" + obj2.value);
  
        //console.log("isEmpty(obj1.value) ::::: " + isEmpty(obj1.value));
        //console.log("isEmpty(obj2.value) ::::: " + isEmpty(obj2.value));
  
        if (!(obj1.value)) {
          obj1.value = lastval.replace('000.','0.');  
          buffer = "";
          lastval= "";
          //checkMaterialSpec(obj1.value, obj2.value);
        } 
        // else if (!(obj2.value)){
        //   obj2.value = serialData;  
        //   checkMaterialSpec(obj1.value, obj2.value);
        // }
        buffer = "";
        lastval= "";
        
        //console.log("buffer2=-----------"+ buffer);
        //console.log("serialData3=-------"+ serialData);
      }   
  });

}
