@REM 🅲 🅷 🅰 🅽 🅳 🅴 🆁
@REM ------------------------------
@REM Chander's DOS shell shortcuts 

@ECHO OFF
SETLOCAL

REM Command Shortcuts
REM -----------------
DOSKEY L=DIR/A/P
DOSKEY LD=DIR/AD/P

DOSKEY ..=CD..
DOSKEY ...=CD..\..
DOSKEY ~=CD /D "%USERPROFILE%"
DOSKEY /=CD \

DOSKEY upgrade="scoop update --all"
