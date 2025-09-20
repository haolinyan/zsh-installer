#!/bin/bash

# 在Ubuntu和Alibaba Cloud Linux系统上安装zsh、oh-my-zsh、其插件和最新Node.js的脚本
# 支持apt、yum和dnf包管理器
# 自动安装oh-my-zsh、zsh-autosuggestions插件并配置主题为cloud
# 这是一个跨平台终端配置方案的一部分

set -e  # 遇到错误时退出脚本

# 检测是否在CI环境中运行
is_ci_environment() {
    if [[ -n "$CI" || -n "$GITHUB_ACTIONS" || -n "$CONTINUOUS_INTEGRATION" || -n "$NON_INTERACTIVE" ]]; then
        echo "检测到CI环境或非交互模式"
        return 0
    else
        return 1
    fi
}

# 检查是否为root用户或有sudo权限
check_permissions() {
    if [ "$(id -u)" -ne 0 ]; then
        if ! command -v sudo &> /dev/null; then
            echo "错误：需要root权限或sudo命令来安装软件包。"
            exit 1
        fi
        echo "将使用sudo执行安装操作..."
        SUDO="sudo"
    else
        SUDO=""
    fi
}

# 检查当前系统是否为Ubuntu或Alibaba Cloud Linux
check_ubuntu() {
    # 检查是否有Debian版本文件（Ubuntu系统会有这个文件）
    if [ -f /etc/debian_version ]; then
        echo "检测到Ubuntu系统，继续安装..."
        return 0
    fi
    
    # 检查是否为Alibaba Cloud Linux
    SYSTEM_NAME=$(cat /etc/os-release 2>/dev/null | grep -E '^NAME=' | cut -d '=' -f 2 | tr -d '"')
    if [[ "$SYSTEM_NAME" == *"Alibaba Cloud Linux"* ]]; then
        echo "检测到Alibaba Cloud Linux系统，继续安装..."
        return 0
    fi
    
    # 如果都不是，则显示错误信息
    if [ -z "$SYSTEM_NAME" ]; then
        SYSTEM_NAME="未知系统"
    fi
    echo "错误：此脚本专为Ubuntu或Alibaba Cloud Linux系统设计，当前系统为 $SYSTEM_NAME，不支持该系统。"
    exit 1
}

# 检查zsh是否已安装
check_zsh_installed() {
    if command -v zsh &> /dev/null; then
        echo "zsh已安装，版本：$(zsh --version)"
        return 0
    else
        echo "zsh未安装，将进行安装..."
        return 1
    fi
}

# 检查oh-my-zsh是否已安装
check_ohmyzsh_installed() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "oh-my-zsh已安装"
        return 0
    else
        echo "oh-my-zsh未安装，将进行安装..."
        return 1
    fi
}

# 安装oh-my-zsh
install_ohmyzsh() {
    echo "安装oh-my-zsh..."
    # 使用官方安装脚本，添加非交互式选项
    if is_ci_environment; then
        # 在CI环境中使用--unattended参数
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        # 在非CI环境中正常安装
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "oh-my-zsh安装成功！"
    else
        echo "错误：oh-my-zsh安装失败。"
        echo "请手动安装oh-my-zsh：sh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
        return 1
    fi
}

# 检查zsh-syntax-highlighting插件是否已安装
check_zsh_syntax_highlighting_installed() {
    ZSH_SYNTAX_HIGHLIGHTING_DIR="$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    if [ -d "$ZSH_SYNTAX_HIGHLIGHTING_DIR" ]; then
        echo "zsh-syntax-highlighting插件已安装"
        return 0
    else
        echo "zsh-syntax-highlighting插件未安装，将进行安装..."
        return 1
    fi
}

# 安装zsh-syntax-highlighting插件
install_zsh_syntax_highlighting() {
    ZSH_SYNTAX_HIGHLIGHTING_DIR="$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    if [ -d "$ZSH_SYNTAX_HIGHLIGHTING_DIR" ]; then
        echo "zsh-syntax-highlighting插件已安装"
        return 0
    fi
    
    echo "安装zsh-syntax-highlighting插件..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_HIGHLIGHTING_DIR"
    
    if [ -d "$ZSH_SYNTAX_HIGHLIGHTING_DIR" ]; then
        echo "zsh-syntax-highlighting插件安装成功！"
    else
        echo "错误：zsh-syntax-highlighting插件安装失败。"
        return 1
    fi
}

# 安装zsh-autosuggestions插件
install_zsh_autosuggestions() {
    ZSH_AUTOSUGGESTIONS_DIR="$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    if [ -d "$ZSH_AUTOSUGGESTIONS_DIR" ]; then
        echo "插件已安装"
        return 0
    fi
    
    echo "安装zsh-autosuggestions插件..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_AUTOSUGGESTIONS_DIR"
    
    if [ -d "$ZSH_AUTOSUGGESTIONS_DIR" ]; then
        echo "zsh-autosuggestions插件安装成功！"
    else
        echo "错误：zsh-autosuggestions插件安装失败。"
        return 1
    fi
}

# 配置zsh主题为cloud
configure_zsh_theme() {
    ZSHRC="$HOME/.zshrc"
    
    # 备份当前的.zshrc文件
    if [ -f "$ZSHRC" ]; then
        cp "$ZSHRC" "$ZSHRC.backup.$(date +%Y%m%d%H%M%S)"
        echo "已备份当前的.zshrc文件"
    fi
    
    echo "配置zsh主题为cloud..."
    
    # 修改ZSH_THEME为cloud
    if grep -q "^ZSH_THEME=" "$ZSHRC"; then
        sed -i "s/^ZSH_THEME=.*/ZSH_THEME='cloud'/" "$ZSHRC"
    else
        echo "ZSH_THEME='cloud'" >> "$ZSHRC"
    fi
    
    # 启用zsh-autosuggestions插件
    echo "启用zsh-autosuggestions插件..."
    if grep -q "^plugins=" "$ZSHRC"; then
        # 如果plugins行已存在，检查是否已包含zsh-autosuggestions
        if ! grep -q "zsh-autosuggestions" "$ZSHRC"; then
            # 在plugins数组中添加zsh-autosuggestions
            sed -i "s/^plugins=(/plugins=(zsh-autosuggestions /" "$ZSHRC"
        fi
    else
        # 如果plugins行不存在，添加新的plugins行
        echo "plugins=(zsh-autosuggestions)" >> "$ZSHRC"
    fi
    
    # 启用zsh-syntax-highlighting插件
    echo "启用zsh-syntax-highlighting插件..."
    if grep -q "^plugins=" "$ZSHRC"; then
        # 如果plugins行已存在，检查是否已包含zsh-syntax-highlighting
        if ! grep -q "zsh-syntax-highlighting" "$ZSHRC"; then
            # 在plugins数组中添加zsh-syntax-highlighting
            sed -i "s/zsh-autosuggestions/zsh-autosuggestions zsh-syntax-highlighting/" "$ZSHRC"
        fi
    else
        # 如果plugins行不存在，添加新的plugins行
        echo "plugins=(zsh-syntax-highlighting)" >> "$ZSHRC"
    fi
    
    echo "zsh配置已更新！"
}

# 检测系统包管理器
detect_package_manager() {
    if command -v apt &> /dev/null; then
        echo "检测到apt包管理器"
        UPDATE_CMD="$SUDO apt update -y"
        INSTALL_CMD="$SUDO apt install -y"
    elif command -v yum &> /dev/null; then
        echo "检测到yum包管理器"
        UPDATE_CMD="$SUDO yum update -y"
        INSTALL_CMD="$SUDO yum install -y"
    elif command -v dnf &> /dev/null; then
        echo "检测到dnf包管理器"
        UPDATE_CMD="$SUDO dnf update -y"
        INSTALL_CMD="$SUDO dnf install -y"
    else
        echo "错误：未检测到支持的包管理器（apt/yum/dnf）。"
        exit 1
    fi
}

# 安装zsh
install_zsh() {
    # 检测包管理器
    detect_package_manager
    
    echo "更新软件包列表..."
    eval $UPDATE_CMD
    
    echo "安装zsh..."
    eval $INSTALL_CMD zsh
    
    if command -v zsh &> /dev/null; then
        echo "zsh安装成功！"
    else
        echo "错误：zsh安装失败。"
        exit 1
    fi
}

# 将zsh设置为默认shell
set_zsh_default() {
    CURRENT_SHELL=$(basename "$SHELL")
    if [ "$CURRENT_SHELL" = "zsh" ]; then
        echo "zsh已经是当前用户的默认shell。"
    else
        # 检查是否在CI环境中
        if is_ci_environment; then
            echo "CI环境：跳过设置默认shell（chsh）操作"
            return 0
        fi
        
        echo "将zsh设置为当前用户的默认shell..."
        chsh -s "$(which zsh)"
        echo "zsh已成功设置为默认shell！"
        echo "注意：请注销并重新登录以应用更改，或直接运行 'zsh' 命令立即使用zsh。"
    fi
}

# 检查Node.js是否已安装
check_nodejs_installed() {
    if command -v node &> /dev/null; then
        echo "Node.js已安装，版本：$(node --version)"
        return 0
    else
        echo "Node.js未安装，将进行安装..."
        return 1
    fi
}

# 安装最新的Node.js
install_nodejs() {
    echo "安装最新的Node.js..."
    
    # 使用NodeSource安装最新的LTS版本
    # 根据包管理器类型安装Node.js
    if [[ "$INSTALL_CMD" == *"apt"* ]]; then
        # Ubuntu/Debian系统
        echo "添加NodeSource PPA..."
        $SUDO apt-get update
        $SUDO apt-get install -y ca-certificates curl gnupg
        $SUDO mkdir -p /etc/apt/keyrings
        curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | $SUDO gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
        
        # 安装最新的LTS版本
        NODE_MAJOR=20
        echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | $SUDO tee /etc/apt/sources.list.d/nodesource.list
        
        $SUDO apt-get update
        $SUDO apt-get install -y nodejs
    elif [[ "$INSTALL_CMD" == *"yum"* || "$INSTALL_CMD" == *"dnf"* ]]; then
        # CentOS/RHEL/Alibaba Cloud Linux系统
        echo "添加NodeSource仓库..."
        NODE_MAJOR=20
        curl -fsSL https://rpm.nodesource.com/setup_$NODE_MAJOR.x | $SUDO bash -
        $INSTALL_CMD nodejs
    else
        echo "错误：不支持的包管理器，无法安装Node.js"
        return 1
    fi
    
    # 验证安装
    if command -v node &> /dev/null; then
        echo "Node.js安装成功！版本：$(node --version)"
        echo "npm版本：$(npm --version)"
        return 0
    else
        echo "错误：Node.js安装失败"
        return 1
    fi
}

# 主函数
main() {
    echo "===== zsh安装脚本 ======"
    
    check_permissions
    check_ubuntu
    
    if ! check_zsh_installed; then
        install_zsh
    fi
    
    set_zsh_default
    
    # 安装git（oh-my-zsh依赖）
    if ! command -v git &> /dev/null; then
        echo "安装git（oh-my-zsh依赖）..."
        detect_package_manager
        eval $INSTALL_CMD git
    fi
    
    # 安装最新的Node.js
    if ! check_nodejs_installed; then
        detect_package_manager  # 确保已设置INSTALL_CMD
        install_nodejs
    fi
    
    # 安装oh-my-zsh
    if ! check_ohmyzsh_installed; then
        install_ohmyzsh
    fi
    
    # 安装zsh-autosuggestions插件
    install_zsh_autosuggestions
    
    # 安装zsh-syntax-highlighting插件
    install_zsh_syntax_highlighting
    
    # 配置zsh主题为cloud
    configure_zsh_theme
    
    echo "
安装完成！您可以通过以下方式启动zsh：
1. 注销并重新登录
2. 直接运行 'zsh' 命令

启动zsh后，您将使用cloud主题，并启用了zsh-autosuggestions和zsh-syntax-highlighting插件。"
    
    echo "===== 脚本执行完毕 ======"
}

# 执行主函数
main