@echo off
echo Iniciando servidor Yupik Outdoor...
echo.

:: Find python
python --version >nul 2>&1
if %errorlevel% == 0 (
    echo Servidor iniciado em http://localhost:8080
    echo A abrir browser...
    start http://localhost:8080/YupikTesouraria.html
    python -m http.server 8080
    goto :end
)

python3 --version >nul 2>&1
if %errorlevel% == 0 (
    echo Servidor iniciado em http://localhost:8080
    echo A abrir browser...
    start http://localhost:8080/YupikTesouraria.html
    python3 -m http.server 8080
    goto :end
)

echo ERRO: Python nao encontrado.
echo Por favor instala Python em https://python.org
pause
:end
