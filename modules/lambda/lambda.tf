resource "aws_iam_role" "lambda_role" {
 name   = var.lambda_iam_role_name
 assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_logging" {

  name         = var.lambda_logging_iam_policy_name
  path         = "/"
  description  = "IAM policy for logging from a lambda"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_attach" {
  role        = aws_iam_role.lambda_role.name
  policy_arn  = aws_iam_policy.lambda_logging.arn
}

resource "aws_lambda_function" "lambda-svc" {
  filename                       = var.filename
  function_name                  = var.lambda_name
  role                           = aws_iam_role.lambda_role.arn
  handler                        = var.lambda_handler_name
  runtime                        = var.lambda_runtime
  depends_on                     = [aws_iam_role_policy_attachment.policy_attach]
}