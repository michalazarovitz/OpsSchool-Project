import jenkins

server = jenkins.Jenkins('http://localhost:8080')
server.build_job('db_pipeline')
server.build_job('midproj_pipeline')