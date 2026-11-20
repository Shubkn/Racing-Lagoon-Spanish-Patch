@echo off
setlocal
cd /d "%~dp0"

rem Uso:
rem   Doble clic -> usa el BIN japones que este junto a este .bat
rem                o, si no existe, work\iso\Racing Lagoon (Japan, Asia).bin
rem   Arrastrar el .bin japones sobre este archivo -> usa ese .bin
rem   APLICAR_PARCHE_ES.bat "ruta\al\japones.bin" "ruta\salida.bin"

set "SRC=%~1"
if "%SRC%"=="" (
    if exist "%~dp0work\iso\Racing Lagoon (Japan, Asia).bin" (
        set "SRC=work\iso\Racing Lagoon (Japan, Asia).bin"
    ) else (
        set "SRC=Racing Lagoon (Japan, Asia).bin"
    )
)

set "OUT=%~2"
if "%OUT%"=="" set "OUT=Racing Lagoon ES.bin"

rem OJO: no usar el nombre XDELTA; xdelta3 lee esa variable de entorno
rem como argumentos extra y el parche fallaria.
set "XD3=%~dp0xdelta3.exe"
if not exist "%XD3%" set "XD3=work\tools\xdelta3-3.2.2-windows-x86_64\xdelta3.exe"

set "HASH_JP=3C475793E4090967D345D0763BB9C0EEF0237C41DFB9F36BF33823C301D7036E"
set "HASH_PREV=E863ECFAE06743336CACC30EECE28E1C5B16D010F06AA9016BA10F02BF2DD69A"
set "HASH_OUT=0316A0ABDFA79C8112F1B49D49D582ACAA041F68C9025B89EDBD68A577135F68"

if not exist "%SRC%" (
    echo No se encontro el BIN de origen:
    echo   "%SRC%"
    echo.
    echo Arrastra el .bin japones sobre este .bat, o pasalo como primer argumento.
    pause
    exit /b 1
)

if not exist "%XD3%" (
    echo No se encontro xdelta3.exe en:
    echo   "%XD3%"
    pause
    exit /b 1
)

for /f "delims=" %%H in ('powershell -NoProfile -Command "(Get-FileHash -Algorithm SHA256 -LiteralPath $env:SRC).Hash"') do set "SRCHASH=%%H"

set "PATCH=RacingLagoonES.xdelta"
if /I "%SRCHASH%"=="%HASH_PREV%" (
    set "PATCH=RacingLagoonES_ACTUALIZACION.xdelta"
    echo Detectado el build ES anterior: se aplicara la actualizacion incremental.
) else (
    if /I not "%SRCHASH%"=="%HASH_JP%" (
        echo ADVERTENCIA: el SHA256 del archivo de origen no coincide con el
        echo BIN japones original ni con el build ES anterior.
        echo   SHA256 encontrado: %SRCHASH%
        echo.
    )
)

if not exist "%PATCH%" (
    echo No se encontro el parche "%PATCH%".
    pause
    exit /b 1
)

echo Archivo original: "%SRC%"
echo Parche:           "%PATCH%"
echo Archivo de salida: "%OUT%"
echo.
echo Aplicando parche...
"%XD3%" -f -d -s "%SRC%" "%PATCH%" "%OUT%"
if errorlevel 1 (
    echo.
    echo ERROR: no se pudo aplicar el parche.
    echo Verifica que el BIN sea la version japonesa correcta SCPS-45404
    echo o el build ES anterior E863EC...
    pause
    exit /b 1
)

echo.
echo Parche aplicado correctamente.
echo SHA256 del archivo generado:
certutil -hashfile "%OUT%" SHA256
echo.
echo Esperado: %HASH_OUT%
echo.
pause
