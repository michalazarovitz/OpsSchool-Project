resource "aws_elb" "jenkins-elb" {
  name               = "jenkins-elb"
  internal = false
  subnets = var.public_subnets.*.id
  security_groups = [var.jenkins-sg]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 8080
    lb_protocol       = "http"
  }

   health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8080"
    interval            = 30
  }

  instances                   = aws_instance.jenkins_master.*.id
  cross_zone_load_balancing   = true
  idle_timeout                = 400
 

  tags = {
    Name = "jenkins-elb"
  }
}

resource "aws_lb_cookie_stickiness_policy" "jenkins-elb-stickiness" {
  name                     = "jenkins-elb-stickiness"
  load_balancer            = "${aws_elb.jenkins-elb.id}"
  lb_port                  = 8080
  cookie_expiration_period = 60
}