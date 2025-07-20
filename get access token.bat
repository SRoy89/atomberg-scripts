echo WRONG
pause

curl -X GET "https://api.developer.atomberg-iot.com/v1/get_access_token" ^
 -H "accept: application/json" ^
 -H "x-api-key: REPLACE" ^
 -H "authorization: Bearer REPLACE"

pause