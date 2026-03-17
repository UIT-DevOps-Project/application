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

    + job 2: build backend và frontend image song song: Ktra tra nếu detect changes == true là có thay đổi thì pipeline này sẽ chạy, GITHUB_TOKEN github sẽ tự sinh sau mỗi lần chạy pipeline, " docker/build-push-action@v5 " sẽ giúp build image theo "context: ./backend" nó sẽ tương tự như " docker build ./backend " . "cache-from: type=gha, cache-to: type=gha,mode=max" build docker layer cache giúp build nhanh hơn tại vì nếu không thay đổi các layer trong dockerfile thì nó sẽ reuse layer cũ không cần build lại từ đầu nên giúp giảm thời gian khi chạy pipeline.
    
    + job 3: Tạo SBOM (Software bill of materials) dùng để liệt kê toàn bộ dependency trong image. Tạo file backend-sbom.json: chứa toàn bộ dependency trong image backend (node,express, openssl, libc) dùng để trace dependency phục vụ cho security + audit

    + job 4: Scan (image, secret, misconfig): 
        + Trivy image: CVE (lỗ hổng) trong image
        + Trivy fs (secret): scan api key, token, password leak
        + Trivy misconfig:  dockerfile sai (run root, open root,... )
    - 3 lớp bảo mật tương ứng cho:
    -                             vuln -> dependency và lưu vào file vuln.json
    -                             secret -> data và lưu vào file misconfig.json
    -                             config -> infra và lưu vào file secret.json

    + job 5: Merge Report: gộp 3 file lại với nhau thành một file report cho dễ đọc, dễ lưu trữ và audit

    + job 6: Upload Artifact cho Scan Report: dùng để lưu trữ file report ở artifact, lưu bằng chứng scan phục vụ cho audit.

    + job 7: enforce: trong trivy-action có exit-code: 1 và severity: HIGH,CRITICAL có nghĩa là nếu có high hoặc critical thì sẽ enforce và stop pipeline không push lên registry.

    + job 8: push code: nếu scan mọi thứ ok rồi thì push lên registry với 2 tag là latest và sha, tag latest để deploy còn tag sha để cho dễ phân biệt và rollback

    + job 9: upload artifact cho SBOM để dễ dàng lưu và audit