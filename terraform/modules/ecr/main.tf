resource "aws_ecr_repository" "repo" {
  name = "ecr-${var.name}"
}
