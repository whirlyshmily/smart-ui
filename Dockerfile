FROM gz-harbor.9n1m.net/crproxy/docker.io/library/node:16.20.2 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm config set registry http://nexus.9n1m.com/repository/npm-cdn-tao/
RUN npm install  --legacy-peer-deps --timeout=60000 --fetch-timeout=600000
COPY . .
RUN npm run build:prod

# production stage
FROM gz-harbor.9n1m.net/crproxy/docker.io/library/nginx:mainline-alpine3.20
COPY --from=builder /app/dist /usr/share/nginx/html
COPY default.conf /etc/nginx/conf.d/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]


# 1. 本地如果是arm架构，但是想构建为x86架构的镜像
# docker buildx build --platform linux/amd64 -t registry.cn-beijing.aliyuncs.com/sunwenbo/smart-ui:latest . --load
# docker push registry.cn-beijing.aliyuncs.com/sunwenbo/smart-ui:latest

# 2. mac m1 本地
#  docker build -t registry.cn-beijing.aliyuncs.com/sunwenbo/smart-ui-arm:latest .
# cd ~/Desktop/docker/
# docker run -itd -p 80:80 -v ./default.conf:/etc/nginx/conf.d/default.conf --name smart-ui  registry.cn-beijing.aliyuncs.com/sunwenbo/smart-ui-arm:latest

# 3. ubuntu服务器
# docker run -itd    -p 80:80   -v /data/smart/default.conf:/etc/nginx/conf.d/default.conf   --name smart-ui   registry.cn-beijing.aliyuncs.com/sunwenbo/smart-ui:latest
