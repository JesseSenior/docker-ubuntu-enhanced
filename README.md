# Docker Ubuntu Enhanced

**注：本项目仅用于个人开发。**

本项目基于官方Ubuntu镜像，在官方镜像的基础上扩展各种功能：

- [x] 支持SSH远程访问（密码/公钥）
- [x] apt更换为国内镜像源（基于：<https://github.com/SuperManito/LinuxMirrors>）
- [x] 支持一键配置Miniconda环境
- [ ] ...

## 使用方法

### Linux 平台

直接运行`scripts/run.sh`即可，脚本将提供交互式手段配置容器。在运行脚本前请确保系统已安装docker。

### Windows 平台

在Windows 10及更高的版本中可以使用`wsl --install`命令安装WSL2。在安装WSL2和Docker后，在项目根目录下执行`bash scripts/run.sh`也能正常运行脚本。（脚本已做WSL2适配。）
