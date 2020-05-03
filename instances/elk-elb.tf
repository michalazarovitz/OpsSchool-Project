resource "aws_elb" "elk-elb" {
  name               = "elk-elb"
  internal = false
  subnets = var.public_subnets.*.id
  security_groups = [var.elk-sg]

  listener {
    instance_port     = 5601
    instance_protocol = "http"
    lb_port           = 5601
    lb_protocol       = "http"
  }

   health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:5601"
    interval            = 30
  }

  instances                   = aws_instance.kibana.*.id
  cross_zone_load_balancing   = true
  idle_timeout                = 400
 

  tags = {
    Name = "elk-elb"
  }
}

resource "aws_lb_cookie_stickiness_policy" "elk-elb-stickiness" {
  name                     = "elk-elb-stickiness"
  load_balancer            = "${aws_elb.elk-elb.id}"
  lb_port                  = 5601
  cookie_expiration_period = 60
}