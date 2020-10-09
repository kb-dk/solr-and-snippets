[Unit]
Description=Apache zookeeper INSTANCE
After=syslog.target network.target remote-fs.target nss-lookup.target systemd-journald-dev-log.socket
[Service]
Type=forking
Environment=JAVA_HOME=JAVA_DIR
WorkingDirectory=/home/zookeeper
PIDFile=/home/format(`zookeeper%s',INSTANCE)/current/data/INSTANCE/zookeeper_server.pid
ExecStart=/home/format(`zookeeper%s',INSTANCE)/current/bin/zkServer.sh start format(`zoo%s.cfg',INSTANCE)
ExecStop=/home/format(`zookeeper%s',INSTANCE)/current/bin/zkServer.sh stop format(`zoo%s.cfg',INSTANCE)
User=zookeeper
Group=zookeeper
[Install]
WantedBy=multi-user.target
