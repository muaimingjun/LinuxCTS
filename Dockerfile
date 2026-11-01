FROM nginx:stable-alpine

# 安装 pandoc（Markdown 转 HTML）
RUN apk add --no-cache pandoc

WORKDIR /usr/share/nginx/html
RUN rm -rf ./*

# 拷贝所有项目文件
COPY . .

# 转换 README.md -> readme.html
# 注意：首页 index.html 由项目自带的导航页提供，不再用 README 覆盖
RUN pandoc README.md -o readme.html --standalone --metadata title="LinuxCTS"

COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
