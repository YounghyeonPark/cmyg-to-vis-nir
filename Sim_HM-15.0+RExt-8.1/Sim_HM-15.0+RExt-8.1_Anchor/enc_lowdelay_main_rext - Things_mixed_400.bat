ECHO OFF

REM ##### ARGUMENT #################################
SET SET=lowdelay_main_rext
REM ################################################

ECHO ###############################################
ECHO  Performance Evaluation for HM(15.0)+RExt(8.1) 
ECHO ###############################################



REM ##### dmlab Anchor ##################################
CALL enc_sub_400.bat %SET% Things_mixed 2576 1920 3 3 -1 22
CALL enc_sub_400.bat %SET% Things_mixed 2576 1920 3 3 -1 27
CALL enc_sub_400.bat %SET% Things_mixed 2576 1920 3 3 -1 32
CALL enc_sub_400.bat %SET% Things_mixed 2576 1920 3 3 -1 37
