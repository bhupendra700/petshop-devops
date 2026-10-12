resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "${var.project_name}-nginx"
  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = var.nginx_image
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project_name}-frontend"
  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = var.frontend_image
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project_name}-backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = var.backend_image
      essential = true

      portMappings = [
        {
          containerPort = 5000
          protocol      = "tcp"
        }
      ]

      secrets = [
        {
          name      = "NODE_ENV"
          valueFrom = "${var.backend_secret_arn}:NODE_ENV::"
        },
        {
          name      = "PORT"
          valueFrom = "${var.backend_secret_arn}:PORT::"
        },
        {
          name      = "JWT_SECRET"
          valueFrom = "${var.backend_secret_arn}:JWT_SECRET::"
        },
        {
          name      = "PAYPAL_CLIENT_ID"
          valueFrom = "${var.backend_secret_arn}:PAYPAL_CLIENT_ID::"
        },
        {
          name      = "AWS_REGION"
          valueFrom = "${var.backend_secret_arn}:AWS_REGION::"
        },
        {
          name      = "AWS_S3_BUCKET_NAME"
          valueFrom = "${var.backend_secret_arn}:AWS_S3_BUCKET_NAME::"
        },
        {
          name      = "ADMIN_NAME"
          valueFrom = "${var.backend_secret_arn}:ADMIN_NAME::"
        },
        {
          name      = "ADMIN_EMAIL"
          valueFrom = "${var.backend_secret_arn}:ADMIN_EMAIL::"
        },
        {
          name      = "ADMIN_PASSWORD"
          valueFrom = "${var.backend_secret_arn}:ADMIN_PASSWORD::"
        },
        {
          name      = "MONGO_URI"
          valueFrom = "${var.backend_secret_arn}:MONGO_URI::"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "nginx" {
  name            = "${var.project_name}-nginx"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx.arn

  desired_count = 0

  launch_type = "FARGATE"

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "nginx"
    container_port   = 80
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }
}

resource "aws_ecs_service" "frontend" {
  name            = "${var.project_name}-frontend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn

  desired_count = 0

  launch_type = "FARGATE"

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  service_registries {
  registry_arn   = aws_service_discovery_service.frontend.arn
  container_name = "frontend"
  container_port = 80
}
}

resource "aws_ecs_service" "backend" {
  name            = "${var.project_name}-backend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn

  desired_count = 0

  launch_type = "FARGATE"

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  service_registries {
  registry_arn   = aws_service_discovery_service.backend.arn
  container_name = "backend"
  container_port = 5000
}
}

# 1. Private DNS Namespace
resource "aws_service_discovery_private_dns_namespace" "main" {
  name = "petshop.local"
  vpc  = var.vpc_id
}

# 2. Frontend Service Discovery
resource "aws_service_discovery_service" "frontend" {
  name = "frontend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# 3. Backend Service Discovery
resource "aws_service_discovery_service" "backend" {
  name = "backend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}