provider "aws" {
  region = "${var.aws_lambda_region}"
}

data "aws_iam_policy" "permit-cwlogs-policy" {
  name = "AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "tfcwlambdarole" {
    statement {
        effect = "Allow"
        actions = ["sts:AssumeRole"]
        principals {
            identifiers = ["lambda.amazonaws.com"]
            type        = "Service"
        }
    }
}



resource "aws_iam_role" "tfcwlambda" {
  name               = "tfcwlambda"
  assume_role_policy = data.aws_iam_policy_document.tfcwlambdarole.json
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attachcwlogs" {
  role       = aws_iam_role.tfcwlambda.name
  policy_arn = data.aws_iam_policy.permit-cwlogs-policy.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "greet_lambda.py"
  output_path = "lambda_function_payload.zip"
}


resource "aws_lambda_function" "greetlambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.zip"
  function_name = "greet_lambda"
  role          = aws_iam_role.tfcwlambda.arn
  handler       = "greet_lambda.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      greeting = "UdacityHello"
    }
  }
}