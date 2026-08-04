ECHO OFF

REM ##### ARGUMENT #################################
SET SET=intra_main_rext
REM ################################################

ECHO ###############################################
ECHO  Performance Evaluation for HM(15.0)+RExt(8.1) 
ECHO ###############################################



REM ##### dmlab Anchor ##################################
CALL enc_sub_rgb.bat %SET% flower_hotmirror 2576 1920 1 1 1 22
CALL enc_sub_rgb.bat %SET% flower_hotmirror 2576 1920 1 1 1 27
CALL enc_sub_rgb.bat %SET% flower_hotmirror 2576 1920 1 1 1 32
CALL enc_sub_rgb.bat %SET% flower_hotmirror 2576 1920 1 1 1 37
