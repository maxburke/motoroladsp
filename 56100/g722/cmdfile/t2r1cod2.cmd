cforce r
force r
change omr $2
load a:\assembly\newg722
input off
input #1 p:$4c a:\cmdfile\moddec2.tst	; DEBI_CDM0
input #2 p:$66 a:\testvect\adst2r1.cod	; DEBI_DCOD
output off
output #1 p:$9d a:\results\calt3l1.rc2	; DEBO_DYL
output #2 p:$a6 a:\results\calt3h1.rc2	; DEBO_DYH
