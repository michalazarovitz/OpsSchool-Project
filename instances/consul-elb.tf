resource "aws_elb" "consul-elb" {
  name               = "consul-elb"
  internal = false
  subnets = var.public_subnets.*.id
  security_groups = [var.consul-sg]

  listener {
    instance_port     = 8500
    instance_protocol = "http"
    lb_port           = 8500
    lb_protocol       = "http"
  }

   health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8500"
    interval            = 30
  }

  instances                   = aws_instance.consul_server.*.id
  cross_zone_load_balancing   = true
  idle_timeout                = 400
 

  tags = {
    Name = "consul-elb"
  }
}

resource "aws_lb_cookie_stickiness_policy" "consul-elb-stickiness" {
  name                     = "consul-elb-stickiness"
  load_balancer            = "${aws_elb.consul-elb.id}"
  lb_port                  = 8500
  cookie_expiration_period = 60
}