#!/bin/sh

# 下载或目录操作失败时停止执行
set -e

mkdir -p ./pbr
cd ./pbr

# ==============================
# 下载 IP 网段数据
# ==============================

# 电信 IPv4
wget --no-check-certificate -c -O ct.txt https://ispip.clang.cn/chinatelecom_cidr.txt

# 联通 IPv4
wget --no-check-certificate -c -O cu.txt https://ispip.clang.cn/unicom_cnc_cidr.txt

# 移动 IPv4
wget --no-check-certificate -c -O cm.txt https://ispip.clang.cn/cmcc_cidr.txt

# 铁通 IPv4
wget --no-check-certificate -c -O crtc.txt https://ispip.clang.cn/crtc_cidr.txt

# 教育网 IPv4
wget --no-check-certificate -c -O cernet.txt https://ispip.clang.cn/cernet_cidr.txt

# 长城宽带 / 鹏博士 IPv4
wget --no-check-certificate -c -O gwbn.txt https://ispip.clang.cn/gwbn_cidr.txt

# 其他 IPv4
wget --no-check-certificate -c -O other.txt https://ispip.clang.cn/othernet.txt

# 所有中国 IPv4
wget --no-check-certificate -c -O cn_ipv4.txt https://ispip.clang.cn/all_cn.txt

# 所有中国 IPv6
wget --no-check-certificate -c -O cn_ipv6.txt https://ispip.clang.cn/all_cn_ipv6.txt

# 移动 IPv6
wget --no-check-certificate -c -O cmcc_ipv6.txt https://ispip.clang.cn/cmcc_ipv6.txt

# 电信 IPv6（新增）
wget --no-check-certificate -c -O ct_ipv6.txt https://ispip.clang.cn/chinatelecom_ipv6.txt


# ==============================
# 生成电信 / 移动策略路由规则
# 输出：ros-pbr-CT-CMCC.rsc
# ==============================

{
  echo "/ip route rule"

  for net in $(cat ct.txt); do
    echo "add dst-address=$net action=lookup table=CT"
  done

  for net in $(cat cu.txt); do
    echo "add dst-address=$net action=lookup table=CT"
  done

  for net in $(cat cm.txt); do
    echo "add dst-address=$net action=lookup table=CMCC"
  done

  for net in $(cat crtc.txt); do
    echo "add dst-address=$net action=lookup table=CMCC"
  done

  for net in $(cat cernet.txt); do
    echo "add dst-address=$net action=lookup table=CT"
  done

  for net in $(cat gwbn.txt); do
    echo "add dst-address=$net action=lookup table=CT"
  done

  for net in $(cat other.txt); do
    echo "add dst-address=$net action=lookup table=CT"
  done

} > ../ros-pbr-CT-CMCC.rsc


# ==============================
# 生成电信 / 移动地址列表
# 包含 IPv4 和 IPv6
# 输出：ros-dpbr-CT-CMCC.rsc
# ==============================

{
  echo "/ip firewall address-list"

  # 电信 IPv4
  for net in $(cat ct.txt); do
    echo "add list=dpbr-CT address=$net"
  done

  # 移动 IPv4
  for net in $(cat cm.txt); do
    echo "add list=dpbr-CMCC address=$net"
  done

  # 所有中国 IPv4
  for net in $(cat cn_ipv4.txt); do
    echo "add list=CNIP address=$net"
  done

  echo "/ipv6 firewall address-list"

  # 电信 IPv6（新增）
  for net in $(cat ct_ipv6.txt); do
    echo "add list=ct_ipv6 address=$net"
  done

  # 移动 IPv6
  for net in $(cat cmcc_ipv6.txt); do
    echo "add list=cmcc_ipv6 address=$net"
  done

  # 所有中国 IPv6
  for net in $(cat cn_ipv6.txt); do
    echo "add list=all_cn_ipv6 address=$net"
  done

} > ../ros-dpbr-CT-CMCC.rsc


# ==============================
# 生成电信 / 联通地址列表
# 输出：ros-dpbr-CT-CU.rsc
# ==============================

{
  echo "/ip firewall address-list"

  for net in $(cat ct.txt); do
    echo "add list=dpbr-CT address=$net"
  done

  for net in $(cat cu.txt); do
    echo "add list=dpbr-CU address=$net"
  done

  for net in $(cat cm.txt); do
    echo "add list=dpbr-CT address=$net"
  done

  for net in $(cat crtc.txt); do
    echo "add list=dpbr-CT address=$net"
  done

  for net in $(cat cernet.txt); do
    echo "add list=dpbr-CT address=$net"
  done

  for net in $(cat gwbn.txt); do
    echo "add list=dpbr-CT address=$net"
  done

  for net in $(cat other.txt); do
    echo "add list=dpbr-CT address=$net"
  done

} > ../ros-dpbr-CT-CU.rsc


# ==============================
# 清理下载目录
# ==============================

cd ..
rm -rf ./pbr

echo "生成完成："
echo "  ros-pbr-CT-CMCC.rsc"
echo "  ros-dpbr-CT-CMCC.rsc（包含电信 IPv6：ct_ipv6）"
echo "  ros-dpbr-CT-CU.rsc"
