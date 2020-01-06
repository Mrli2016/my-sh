
#! /bin/sh
###
# @Author: 李永兴
# @Email: mrli2016@126.com
# @Date: 2020-01-05 21:29:23
 # @LastEditTime : 2020-01-06 11:28:59
# @Description: 
###

# 创建常用文件夹
mkdir -p /web/www/
mkdir -p /web/git/

# 卸载旧版docker文件
systemctl stop docker
yum erase docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine \
                  docker-ce

find /etc/systemd -name '*docker*' -exec rm -f {} \;
find /etc/systemd -name '*docker*' -exec rm -f {} \;
find /lib/systemd -name '*docker*' -exec rm -f {} \;
rm -rf /var/lib/docker   #删除以前已有的镜像和容器,非必要
rm -rf /var/run/docker  
# 安装最新版docker
yum install -y yum-utils  device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce -y
# 安装 docker-compose
yum -y install epel-release
pip install --upgrade pip

# 安装git
yum install git -y

sudo adduser git

alias cgit='cgit() {
  echo 生成$1仓库; 
  mkdir -p /web/git/$1.git;
  cd /web/git/$1.git;
  git init --bare;
  chown -R git /web/git/$1.git;
  cd hooks;

  touch post-receive;
  echo -e "#!/bin/sh\t\t" > post-receive;
  echo -e "# 打印输出\t" >> post-receive;
  echo -e "echo \"======上传代码到 $1 服务器======\"\t" >> post-receive;
  echo -e "# 打开线上项目文件夹\t" >> post-receive;
  echo -e "cd /web/www/$1\t" >> post-receive;
  echo -e "# 这个很重要，如果不取消的话将不能在cd的路径上进行git操作\t" >> post-receive;
  echo -e "unset GIT_DIR\t" >> post-receive;
  echo -e "git pull origin master\t" >> post-receive;
  echo -e "echo \$(date) >> hook.log\t" >> post-receive;
  echo -e "echo \"====== $1 仓库代码更新完成======\"\t" >> post-receive;
  echo -e "\t" >> post-receive;
  chmod +x post-receive

  cd /web/www;
  git clone /web/git/$1.git;
  chown -R git /web/www/$1
  echo 完成; 
};cgit'

