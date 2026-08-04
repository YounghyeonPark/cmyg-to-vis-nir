ECHO OFF

REM ##### ARGUMENT #################################
SET SET=%1
SET SEQ_NAME=%2
SET WIDTH=%3
SET HEIGHT=%4
SET FRM_RATE=%5
SET FRM_NUM=%6
SET INTRA_PERIOD=%7
SET QP=%8
REM ################################################

REM ##### SET VARIABLE #############################
SET IN_NAME=%2
SET OUT_NAME=%1_%2_%3x%4_%5_QP%8
SET METHOD=Anchor
REM ################################################

ECHO ###############################################
ECHO  Encoding: %METHOD%_%OUT_NAME%
ECHO -----------------------------------------------

TAppEncoder_%METHOD%.exe -c cfg\encoder_%SET%.cfg -c encoder_RGB.cfg -i ..\org\%IN_NAME%.rgb -b str\%OUT_NAME%.bin -o rec\%OUT_NAME%.rgb -wdt %WIDTH% -hgt %HEIGHT% -fr %FRM_RATE% -f %FRM_NUM% -q %QP% -ip %INTRA_PERIOD% > stat\%OUT_NAME%.txt

ECHO -----------------------------------------------
ECHO  Terminated Encoding... 
ECHO ###############################################
