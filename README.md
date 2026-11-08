# VCamFit —— 让千面/VCam 的替换图完整显示

## 它干什么

VCam 把替换图贴到相机画面上时，用的缩放模式是 `CropSourceToCleanAperture`（只截左上角，不缩放）。
这个插件在 `mediaserverd` 进程里把该值改成 `Letterbox`（等比缩放到完整可见，四周补边）。

**不改原包、不动二进制、不需要重签名**，装/卸都不影响 VCam 本身。

## Mac 上三步

### 1. 装 Xcode 命令行工具（如果没装过）

```bash
xcode-select --install
```

### 2. 装 Theos

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"
```

装完确认：

```bash
echo $THEOS          # 应输出 ~/theos
$THEOS/bin/nic.pl -l | head
```

如果 `$THEOS` 是空的，写进 shell 配置：

```bash
echo 'export THEOS=~/theos' >> ~/.zshrc
echo 'export PATH=$THEOS/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
```

### 3. 编译

把整个 `theos_project` 文件夹拷到 Mac（U 盘 / 微信 / 网盘都行），然后：

```bash
cd theos_project
make package
```

第一次会下载 SDK，等几分钟。成功后产物在：

```
packages/com.yg.vcamfit_1.0.0_iphoneos-arm64.deb
```

## 装到手机

方式一（推荐，最省事）：把这个 deb 用微信/网盘发到手机 → Filza 打开 → 安装。

方式二：Mac 装 `libimobiledevice`，用 `iproxy` 转发后 scp 上去（需要手机开 SSH）。

## 验证

装完重启一次（或 `killall -9 mediaserverd`），进货拉拉看：

- 画面完整、四周有黑边 → 成功
- 画面填满但裁边 → 说明它用的是 Trim，把 Tweak.xm 里的 `Letterbox` 换成 `Trim` 重新编译
- 完全没变化 → 说明这条设置不在 `VTSessionSetProperty` 上，需要换 hook 点，告诉我现象

## 卸载

Sileo 里卸载 `VCamFit` 即可，不会影响 VCam。

## 备注

`Tweak.xm` 里限定了只在 `mediaserverd` 生效，不会影响别的 App 播放视频。
