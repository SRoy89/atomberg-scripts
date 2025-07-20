@echo off
setlocal EnableDelayedExpansion

:: Set API key and refresh token
set "API_KEY=REPLACE"
set "DEVICE_ID=REPLACE"
set "REFRESH_TOKEN=REPLACE_REPLACE"

:: Get access token
echo Fetching access token...
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command ^
    "$headers = @{ 'accept' = 'application/json'; 'authorization' = 'Bearer %REFRESH_TOKEN%'; 'x-api-key' = '%API_KEY%' }; " ^
    "$response = Invoke-RestMethod -Uri 'https://api.developer.atomberg-iot.com/v1/get_access_token' -Headers $headers -Method Get; " ^
    "Write-Output $response.message.access_token"`) do set ACCESS_TOKEN=%%A
 
:: Delay before turning fan off
:: echo Waiting 3 seconds before turning fan OFF...
:: timeout /t 3 >nul

:: Send power off
echo Turning fan OFF...
curl -s -X POST "https://api.developer.atomberg-iot.com/v1/send_command" ^
 -H "accept: application/json" ^
 -H "authorization: Bearer %ACCESS_TOKEN%" ^
 -H "content-type: application/json" ^
 -H "x-api-key: %API_KEY%" ^
 -d "{\"device_id\":\"%DEVICE_ID%\",\"command\":{\"power\":0}}"

echo .
::timeout /t 30
echo .
echo Waiting for user activity to turn fan back ON...

:waitloop
powershell -Command ^
  "Add-Type -AssemblyName System.Windows.Forms; " ^
  "$t1 = [Windows.Forms.Cursor]::Position; Start-Sleep -Milliseconds 1000; " ^
  "$t2 = [Windows.Forms.Cursor]::Position; " ^
  "if ($t1.X -ne $t2.X -or $t1.Y -ne $t2.Y -or [Console]::KeyAvailable) { exit 0 } else { exit 1 }"
if %errorlevel%==1 goto waitloop

:: Turn fan ON
echo Activity detected! Turning fan ON...
curl -s -X POST "https://api.developer.atomberg-iot.com/v1/send_command" ^
 -H "accept: application/json" ^
 -H "authorization: Bearer %ACCESS_TOKEN%" ^
 -H "content-type: application/json" ^
 -H "x-api-key: %API_KEY%" ^
 -d "{\"device_id\":\"%DEVICE_ID%\",\"command\":{\"power\":1}}"