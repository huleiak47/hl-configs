https://www.horosama.com/archives/326

在 wsl2 推出了镜像网络模式之后，第一时间进行了试用，但之前就发现这个模式下，如果同时开启了代理的 tun 模式(fake-ip)，会出现在 wsl 内无法正常上网的问题。测试方法如下，使用 curl https://baidu.com -v，观察发现一直卡在 TLS 握手阶段，无法正常链接，然后 apt-get update 命令也会运行失败。

v2 论坛上可以看到类似问题的反馈，参考 WSL2 今天史诗级更新 - V2EX。

经过一系列的测试，今天终于发现了解决问题的办法，在这里分享一下。

# 原因定位

一句话解释，tun 模式下的虚拟网卡的 mtu 值是 9000，修改为 1500 就可以了。

# 修复方法

首先我们用 ifconfig 查看 wls2 内的网卡，然后记下 ip 地址为 198.18.0.1 的网卡的名字，如 eth4。

root 用户身份，运行如下命令： `echo -e "[Unit]\nDescription=clash tun mtu fix\nAfter=network-online.target\n\n[Service]\nExecStart=$(which ip) link set eth4 mtu 1500\n\n[Install]\nWantedBy=multi-user.target" | sudo tee /etc/systemd/system/mtufix.service` , 将 eth4 修改为你上一步记下的名字，然后运行命令

```shell
systemctl enable mtufix.service
systemctl start mtufix.service
```

重新进行测试，此时发现已经可以正常联网了，google 也可以正常连接。
