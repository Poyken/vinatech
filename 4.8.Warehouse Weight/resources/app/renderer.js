// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// All of the Node.js APIs are available in this process.

const serialport = require("serialport");
//const tableify = require('tableify')

serialport.list(/*(err, ports)*/).then(function (err, ports) {
  if (err && !ports) ports = err;
  console.log("ports", ports);

  if (err && err.message) {
    document.getElementById("errorid").innerHTML = err.message;
    return;
  } else {
    document.getElementById("errorid").innerHTML = " ";
    document.getElementById("portid").innerHTML = " ";
  }

  if (ports.length === 0) {
    document.getElementById("errorid").innerHTML = "Không tìm thấy cổng COM";
  }

  ports.forEach(function (port) {
    console.log("Port: ", port);
    document.getElementById("portid").innerHTML =
      document.getElementById("portid").innerHTML +
      port.path +
      "_" +
      port.manufacturer +
      "   ;   ";
  });

  //tableHTML = tableify(ports)
  //document.getElementById('errorid').innerHTML = tableHTML
});
