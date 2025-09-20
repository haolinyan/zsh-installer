# zsh-installer

一个用于在Ubuntu和Alibaba Cloud Linux系统上自动安装和配置zsh、oh-my-zsh及其插件的脚本工具。

## 国内优化版本

针对国内用户网络环境，我们还提供了使用国内镜像源的优化版本 `zsh-installer-cn.sh`，可以显著提高安装速度和成功率。

## 功能特点

- 安装zsh并设置为默认shell
- 安装oh-my-zsh框架
- 安装并配置zsh-autosuggestions插件
- 安装并配置zsh-syntax-highlighting插件
- 配置zsh主题为cloud
- 安装最新的Node.js (LTS版本)

## 支持的系统

- Ubuntu系统（检测/etc/debian_version文件）
- Alibaba Cloud Linux系统（检测系统名称）

## 安装要求

- 具有root权限或sudo权限
- 已连接互联网
- 系统已安装curl和git

## 使用方法

### 基本安装

1. 下载脚本

   ```bash
   curl -O https://raw.githubusercontent.com/[your-username]/zsh-installer/main/zsh-installer.sh
   ```

2. 设置执行权限

   ```bash
   chmod +x zsh-installer.sh
   ```

3. 运行脚本

   ```bash
   ./zsh-installer.sh
   ```

4. 安装完成后，注销并重新登录，或者直接运行以下命令启动zsh：

   ```bash
   zsh
   ```

### 国内优化版本安装

针对国内用户网络环境，我们提供了使用国内镜像源的优化版本，可以显著提高安装速度和成功率：

1. 下载国内优化版本脚本

   ```bash
   curl -O https://raw.githubusercontent.com/[your-username]/zsh-installer/main/zsh-installer-cn.sh
   ```

2. 设置执行权限

   ```bash
   chmod +x zsh-installer-cn.sh
   ```

3. 运行脚本

   ```bash
   ./zsh-installer-cn.sh
   ```

4. 安装完成后，注销并重新登录，或者直接运行以下命令启动zsh：

   ```bash
   zsh
   ```

### 脚本执行流程

1. **权限检查**：验证是否具有足够的权限执行安装操作
2. **系统检查**：确认当前系统是Ubuntu或Alibaba Cloud Linux
3. **zsh安装**：如果zsh未安装，则使用系统包管理器安装
4. **设置默认shell**：将zsh设置为当前用户的默认shell（在CI环境中会跳过此步骤）
5. **git安装**：如果git未安装，则安装git（oh-my-zsh依赖）
6. **Node.js安装**：如果Node.js未安装，则安装最新的Node.js LTS版本
7. **oh-my-zsh安装**：如果oh-my-zsh未安装，则安装oh-my-zsh框架
8. **插件安装**：安装zsh-autosuggestions和zsh-syntax-highlighting插件
9. **主题配置**：配置zsh使用cloud主题

### 国内优化版本特性

国内优化版本 (`zsh-installer-cn.sh`) 在保持功能一致性的基础上，针对国内网络环境进行了以下优化：

1. **oh-my-zsh安装源**：使用Gitee镜像替代GitHub源
2. **插件下载源**：zsh-syntax-highlighting和zsh-autosuggestions插件均使用Gitee镜像
3. **Node.js安装源**：使用腾讯云镜像源替代官方源
4. **其他依赖**：系统包管理器使用国内镜像（需用户自行配置）

注意：国内优化版本假设系统的包管理器已配置为使用国内镜像源。如果没有配置，建议先配置APT或YUM的国内镜像源，以获得最佳的下载速度。

## GitHub Actions CI测试

本项目包含完整的GitHub Actions CI配置，可以在每次代码push或创建pull request时自动测试脚本功能。测试在Ubuntu环境中运行，验证脚本是否能正确安装和配置所有组件。

CI配置文件位于 `.github/workflows/test.yml` <mcfile name="test.yml" path="/Users/yanhaolin/Desktop/zsh-installer/.github/workflows/test.yml"></mcfile>，测试流程包括：

1. **代码检出**：从GitHub仓库检出最新代码
2. **设置权限**：为脚本文件添加执行权限
3. **安装依赖**：安装curl和git等必要工具
4. **执行测试**：运行脚本并验证所有组件的安装状态
5. **结果验证**：检查以下内容是否正确安装和配置：
   - zsh shell
   - oh-my-zsh框架
   - zsh-autosuggestions插件
   - zsh-syntax-highlighting插件
   - .zshrc配置文件（主题设置和插件启用）

测试配置会捕获脚本输出，检查执行退出码，并提供详细的测试结果日志，确保脚本在Ubuntu环境中的稳定性和可靠性。

## 注意事项

- 脚本在执行过程中遇到错误会自动退出，请根据错误信息排查问题
- 在CI环境中，脚本会自动跳过设置默认shell的操作，以避免权限问题
- 脚本会自动备份现有的.zshrc文件，备份文件名为 `.zshrc.backup.时间戳`
- 如果安装过程中断或失败，可以重新运行脚本继续安装
- 安装完成后，建议注销并重新登录以应用默认shell的更改

## 常见问题

### Q: 脚本提示"需要root权限或sudo命令"怎么办？
A: 请使用具有sudo权限的用户运行脚本，或者切换到root用户执行。

### Q: 脚本提示"不支持该系统"怎么办？
A: 本脚本仅支持Ubuntu和Alibaba Cloud Linux系统，如果您使用的是其他系统，需要手动安装和配置zsh。

### Q: 安装完成后，zsh主题没有生效怎么办？
A: 请检查 `.zshrc` 文件中的 `ZSH_THEME` 设置是否为 `'cloud'`，如果不是，请手动修改并运行 `source ~/.zshrc` 应用更改。

### Q: 插件没有生效怎么办？
A: 请检查 `.zshrc` 文件中的 `plugins` 设置是否包含 `zsh-autosuggestions` 和 `zsh-syntax-highlighting`，如果没有，请手动添加并运行 `source ~/.zshrc` 应用更改。

### Q: 国内优化版本安装速度仍然很慢怎么办？
A: 国内优化版本主要优化了GitHub相关资源的访问速度。如果系统包管理器的安装速度仍然很慢，建议配置APT或YUM使用国内镜像源：
   - Ubuntu: 配置 `/etc/apt/sources.list` 使用阿里云、清华等镜像站
   - Alibaba Cloud Linux: 系统默认已使用阿里云镜像源

## License

MIT License