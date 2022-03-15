output "ipset_location" {
  value = "s3://${aws_s3_object.ipset.bucket}/${aws_s3_object.ipset.key}"
}

output "threatintelset_location" {
  value = "s3://${aws_s3_object.threatintelset.bucket}/${aws_s3_object.threatintelset.key}"
}

