# 编译
FROM golang:alpine AS builder

# 切换模块源为中国Go模块代理服务器
# RUN go env -w GOPROXY=https://goproxy.cn,direct

# 拉取代码
RUN go install tailscale.com/cmd/derper@latest

# 编译（静态链接，避免依赖系统库）
RUN derper_dir=$(find /go/pkg/mod/tailscale.com@*/cmd/derper -type d) && \
	cd $derper_dir && \
    CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o /etc/derp/derper

# 生成最终镜像
FROM alpine:latest

WORKDIR /apps

COPY --from=builder /etc/derp/derper .

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone

ENV LANG=C.UTF-8

# 添加源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

# 创建证书目录（IP 方式会自动生成自签名证书）
RUN mkdir /ssl

# 设置环境变量，可通过 docker-compose 覆盖
ENV DERP_HOSTNAME="" \
    DERP_PORT="3478" \
    DERP_CERTDIR="/ssl"

CMD ["./derper", "-hostname", "$DERP_HOSTNAME", "-a", ":$DERP_PORT", "-certmode", "manual", "-certdir", "$DERP_CERTDIR", "--verify-clients"]