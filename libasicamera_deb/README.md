# 產生 libasicamera 的 deb 套件包
## 取得 SDK 檔
```
cd src
wget http://astronomy-imaging-camera.com/software/ASI_linux_mac_SDK_V0.4.0929.tar
```
## 解開 SDK 檔
```
tar xvf ASI_linux_mac_SDK_V0.4.0929.tar -O | tar xjvf - --one-top-level=ASI_SDK
```

## 複製產生 deb 套件包需要的檔案, 至相關目錄
```
rm -rf ../deb_root/*
mkdir -p ../deb_root/lib/udev/rules.d/
mkdir -p ../deb_root/usr/include/
mkdir -p ../deb_root/usr/lib/
```
```
cp -a ASI_SDK/lib/asi.rules ../deb_root/lib/udev/rules.d/
cp -a ASI_SDK/include/ASICamera*.h ../deb_root/usr/include/
cp -a ASI_SDK/lib/armv7/libASICamera*.a ../deb_root/usr/lib/
cp -a ASI_SDK/lib/armv7/libASICamera*.so.0.* ../deb_root/usr/lib/
```
```
rm -rf ASI_SDK
rm -f ASI_linux_mac_SDK_V0.4.0929.tar
```
## 編輯版本資訊
```
cd ../
vi build.xml 修改以下 name 參數 value 的容
  <property name="package_version" value="0.4.0929"/>
  <property name="debian_version" value="1"/>
  <property name="deb_depends" value="libusb-1.0-0"/>
  <property name="maintainer" value="Cheng-Chang Ho"/>
  <property name="maintainer_email" value="earlybird.astro@gmail.com"/>
  <property name="brief" value="ZWO ASI Camera SDK"/>
  <property name="description" value=" Software Development Kit for ZWO ASI Cameras."/>
```
```
vi changelog 修改
```
## 下載產生 deb 套件包所需工具 library
```
ant clean
ant prepare
```

## 產生 deb 套件包
```
ant deb
```

# 上傳 libasicamera 的 deb 套件包, 至 Repository Server
TODO: tagert: up 加入 build.xml 或是 WEB Upload
```
scp dist/libasicamera_0.4.0929-1_armhf.deb to Repository Sserver
```

## 將 Repository Server 上的 libasicamera 的 deb 套件包, 加入 repository
TODO: 自動 reprepro
```
reprepro -b . -C main includedeb xenial /home/hcc/libasicamera_0.4.0929-1_armhf.deb
```
