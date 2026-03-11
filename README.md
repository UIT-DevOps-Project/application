# Config dockerfile and dockercompose
## Dockerfile of Backend:
```RUN apt-get update && apt-get install -y libssl1.1```
xóa dòng này bởi vì ở node 20 + Prisma đã dùng OpenSSl 3 có sẵn.

``` RUN npm ci --omit=dev ```
thêm --omit=dev để không cài các package trong devDependecies. Tại vì trong production container chỉ cần dependency chạy app không cần các thành phần phụ như eslint, prettier, jest, typescript, test frameworks
=>> Sau khi build lại image giảm từ 500MB xuống còn 450MB

## Create Docker compose
Tạo docker compose ở root để thuận tiện compose các thành phần đơn lẻ, trong docker compose có đính kèm backend, frontend, PostgreDB. Ở backend và frontend sẽ kéo image có tag latest về để thay đổi code thuận tiện cho CI/CD

Sử dụng câu lệnh này để chạy dự án:
``` docker compose up -d ```

Khi push image mới lên dockerhub chỉ cần chạy câu lệnh này và sau đó compose up lại:

``` docker compose pulll ```

Xem Dockerfile backend, Dockerfile frontend và Docker compose để xác định được port đang chạy của các service