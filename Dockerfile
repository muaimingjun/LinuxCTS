FROM nginx:stable-alpine

# 安装 pandoc（Markdown 转 HTML）
RUN apk add --no-cache pandoc

WORKDIR /usr/share/nginx/html
RUN rm -rf ./*

# 拷贝所有项目文件
COPY . .

# 转换 README.md -> index.html
RUN pandoc README.md -o index.html --standalone --metadata title="LinuxCTS"

COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
