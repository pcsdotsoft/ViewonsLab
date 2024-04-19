# TODO: Define the output variable for the lambda function.
output "greetlambda" {
  value = "${aws_lambda_function.greetlambda.qualified_arn}"
}