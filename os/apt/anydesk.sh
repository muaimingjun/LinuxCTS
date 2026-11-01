



# 定义变量
URL="https://cdn.wanwuhuanxin.cn/app/anydesk_7.1.2-1_amd64.deb"
FILENAME="anydesk_install.deb"
SOURCE_DOMAIN="dev.itgpt.top"

echo "------------------------------------------------"
echo "正在从 $SOURCE_DOMAIN 获取安装资源..."
echo "------------------------------------------------"

# 1. 下载安装包
echo "步骤 1: 正在下载 AnyDesk..."
wget -O $FILENAME $URL

# 2. 使用 apt 安装（自动补全依赖）
echo "步骤 2: 正在安装并补全依赖..."
sudo apt install ./$FILENAME -y
sudo sed -i 's/#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf
# 3. 清理临时文件
echo "步骤 3: 正在清理安装包..."
rm $FILENAME

echo "------------------------------------------------"
echo "安装完成！你可以在应用程序菜单中找到 AnyDesk。"
echo "脚本来源及技术支持：$SOURCE_DOMAIN"
echo "------------------------------------------------"

clear 
echo '等待 30秒后，输出设备码。'
time sleep 30

echo "远程的设备码是：$(anydesk --get-id)"