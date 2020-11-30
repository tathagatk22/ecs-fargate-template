resource "aws_ecr_repository" "ecr_repo" {
  name = "node-ecr-repo"
  # image_tag_mutability = "MUTABLE" # default
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster"
}


resource "aws_ecs_task_definition" "task_defination" {
  family = "node-task-1"
  container_definitions = <<DEFINITION
  [
    {
      "name": "node-task",
      "image": "${aws_ecr_repository.ecr_repo.repository_url}:${var.tag}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ],
      "memory": 256,
      "cpu": 50
    }
  ]
  DEFINITION
  requires_compatibilities = [
    "FARGATE"]
  network_mode = "awsvpc"
  memory = 512
  cpu = 256
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_service" "node-service" {
  depends_on = [
    aws_lb_listener.https_forward,
    aws_ecs_task_definition.task_defination
  ]
  name = "node"
  cluster = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_defination.arn
  desired_count = 3
  launch_type = "FARGATE"
  network_configuration {
    subnets = [
      aws_subnet.subnet_private.id,
      aws_subnet.subnet_private_2.id]
    security_groups = [
      aws_security_group.security-group.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_target_group.arn
    container_name = "node-task"
    container_port = 80
  }
  force_new_deployment = true
}
