resource "aws_ecs_cluster" "my_cluster" {
  name = "my-cluster"
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
lifecycle {
    prevent_destroy = true
  }
}

# Attach the required AWS policy to the IAM role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_cloudwatch_log_group" "my_app_log_group" {
  name              = "/ecs/my-app"
  retention_in_days = 7
}
resource "aws_ecs_task_definition" "my_task" {
  family                   = "my-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  container_definitions    = <<DEFINITION
  [
    {
      "name": "my-app",
      "image": "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/my-ecr-repo:latest",
      "memory": 512,
      "cpu": 256,
      "essential": true,
      "networkMode": "awsvpc",
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ],
"logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/my-app",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "my-app"
      }
    }
   }
  ]
  DEFINITION
}

resource "aws_lb" "my_alb" {
  name               = "my-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "my_target_group" {
  name     = "my-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
  }
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}
resource "aws_ecs_service" "my_service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

load_balancer {
    target_group_arn = aws_lb_target_group.my_target_group.arn
    container_name   = "my-app"
    container_port   = 80
  }

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = var.security_group_ids
    assign_public_ip = true
  }
deployment_controller {
    type = "ECS"
  }

  force_new_deployment = true
}