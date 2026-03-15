# Config dockerfile and dockercompose
## Dockerfile of Backend:
```RUN apt-get update && apt-get install -y libssl1.1```
- xóa dòng này bởi vì ở node 20 + Prisma đã dùng OpenSSl 3 có sẵn.

``` RUN npm ci --omit=dev ```
- thêm --omit=dev để không cài các package trong devDependecies. Tại vì trong production container chỉ cần dependency chạy app không cần các thành phần phụ như eslint, prettier, jest, typescript, test frameworks
=>> Sau khi build lại image giảm từ 500MB xuống còn 450MB

## Create Docker compose
- Tạo docker compose ở root để thuận tiện compose các thành phần đơn lẻ, trong docker compose có đính kèm backend, frontend, PostgreDB. Ở backend và frontend sẽ kéo image có tag latest về để thay đổi code thuận tiện cho CI/CD

- Sử dụng câu lệnh này để chạy dự án:
``` docker compose up -d ```

- Khi push image mới lên dockerhub chỉ cần chạy câu lệnh này và sau đó compose up lại:

``` docker compose pulll ```

- Xem Dockerfile backend, Dockerfile frontend và Docker compose để xác định được port đang chạy của các service


# Config pipeline CI for project
- Tạo pipeline sử dụng path-filter để lọc, pipeline này chạy khi thay đổi backend, frontend, dockerfile,
dockercompose, .github/workflows/*.
- Đầu tiên là paths khi push vào main hoặc pull request vào main thì sẽ lấy path của các backend, frontend, dockerfile, dockercompose, .github/workflows/*
- Pipeline có 3 jobs
    + job 1: detect changes: dùng để phát hiện sử thay đổi nếu backend thay đổi thì chỉ chạy pipeline backend còn nếu frontend thay đổi thì chỉ chạy pipeline frontend và nếu thay đổi cả backend và frontend thì 2 pipeline sẽ chạy xong xong , còn nếu dockerfile, dockercompose, .github/workflows/* thay đổi thì chạy cả 2 pipeline để build lại và xem pipeline có bị lỗi hay gì không. Ở jobs này output khi filter sẽ trả về true hoặc false dựa vào đó để filter cho backend và frontend
    + job 2: build backend: Ktra tra nếu detect changes == true là có thay đổi thì pipeline này sẽ chạy, GITHUB_TOKEN github sẽ tự sinh sau mỗi lần chạy pipeline, " docker/build-push-action@v5 " sẽ giúp build image theo "context: ./backend" nó sẽ tương tự như " docker build ./backend " và sau khi build xong sẽ gắn 2 tag cho image 1 là tag latest để thuận tiên cho việc deploy còn 1 tag là SHA để thuận tiện cho việc rollback sau đó push lên GHCR của github owner. "cache-from: type=gha, cache-to: type=gha,mode=max" build docker layer cache giúp build nhanh hơn tại vì nếu không thay đổi các layer trong dockerfile thì nó sẽ reuse layer cũ không cần build lại từ đầu nên giúp giảm thời gian khi chạy pipeline.
    + job 3: tượng tự backend chỉ đổi thành frontend.