@echo off

rem cd C:\Users\kaimos\Desktop\capture\01.11.electrode.weighing.x64\electrode.weighing.x64\resources\app\SendWeightToLabelPrint

java -cp .;./lib/gson-2.8.0.jar;./lib/json-20140107.jar;./lib/spring-beans-5.0.8.RELEASE.jar;./lib/spring-core-5.0.8.RELEASE.jar;./lib/spring-jcl-5.0.8.RELEASE.jar;./lib/spring-web-5.0.8.RELEASE.jar;./lib/sqljdbc4-2.0.jar;./lib/jssc.jar com.vinatech.serial.SerialWriter %1 %2
