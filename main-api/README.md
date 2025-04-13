```
curl -X POST http://localhost:3000/auth/register \
  -c cookies.txt \
  -H "Content-Type: application/json" \
  -d '{"full_name": "Иванов Иван Иванович", "age": 30, "document_type": "passport", "document_number": "1234 567890", "password": "123456", "password_confirmation": "123456"}'
```

```
curl -X GET http://localhost:3000/users/1 -H "Content-Type: application/json"
```