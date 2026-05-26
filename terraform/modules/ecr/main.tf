resource "aws_ecr_repository" "repo" {
  name = "ecr-${var.name}"
  force_delete = true
}
