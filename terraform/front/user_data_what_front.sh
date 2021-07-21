#!/bin/bash
apt -y update
apt -y install tomcat9
curl -L -X GET "nexus-LoadB-27OMUYNALY1Z-837220146.us-east-2.elb.amazonaws.com/service/rest/v1/search/assets/download?sort=version&repository=what-front"\
 -H "accept: application/json" --output - | tar -xzf -  -C /var/lib/tomcat9/webapps/ROOT package/dist --strip-components=2
