resource "aws_ecr_repository" "docker_repository" {
  for_each = {
    for i, ecr_repo in var.ecr.repos : ecr_repo.name => ecr_repo
  }

  name                 = each.value.name
  image_tag_mutability = each.value.image_tag_mutability
  encryption_configuration {
    encryption_type = each.value.encryption_configuration.encryption_type
  }
  image_scanning_configuration {
    scan_on_push = each.value.image_scanning_configuration.scan_on_push
  }

  tags = var.tags
}
