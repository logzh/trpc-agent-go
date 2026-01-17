FROM golang:1.24

ARG GOLANGCI_LINT_VERSION=v2.3.0

# 安装 code-server 和 vscode 常用插件
RUN curl -fsSL https://code-server.dev/install.sh | sh \
  && code-server --install-extension cnbcool.cnb-welcome \
  && code-server --install-extension redhat.vscode-yaml \
  && code-server --install-extension dbaeumer.vscode-eslint \
  && code-server --install-extension waderyan.gitblame \
  && code-server --install-extension mhutchie.git-graph \
  && code-server --install-extension donjayamanne.githistory \
  && code-server --install-extension golang.go \
  && code-server --install-extension ms-python.python \
  && code-server --install-extension tencent-cloud.coding-copilot \
  && code-server --install-extension humao.rest-client \
  && echo done
  
# 安装 ssh 服务，用于支持 VSCode 等客户端通过 Remote-SSH 访问开发环境（也可按需安装其他软件）
RUN apt-get update && apt-get install -y git git-lfs wget unzip openssh-server zsh  && \
   go install golang.org/x/tools/cmd/goimports@latest && \
   curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin ${GOLANGCI_LINT_VERSION}

# 安装 oh-my-zsh 并配置插件（git, zsh-autosuggestions, zsh-syntax-highlighting）
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    if ! grep -q "plugins=(git" /root/.zshrc; then \
        sed -i 's/^plugins=(/plugins=(git zsh-autosuggestions zsh-syntax-highlighting /' /root/.zshrc || \
        sed -i '/^plugins=/c\plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' /root/.zshrc; \
    else \
        sed -i 's/plugins=(git/plugins=(git zsh-autosuggestions zsh-syntax-highlighting/' /root/.zshrc; \
    fi && \
    chsh -s $(which zsh)

# 指定字符集支持命令行输入中文（根据需要选择字符集）
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
