################################################################################
# https://www.terraform.io/docs/providers/aws/r/cloudwatch_dashboard.html
# https://www.terraform.io/docs/configuration/expressions.html#directives
# TODO: Add memory and OS metrics if the CloudWatch agent is installed

resource "aws_cloudwatch_dashboard" "cloudwatch_dashboard" {
  dashboard_name = "${var.name}-${random_id.id.hex}"
  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 24,
            "height": 3,
            "properties": {
                "metrics": [
                  %{ for id in aws_instance.ec2_instance.*.id }
                    [ "AWS/EC2", "CPUUtilization", "InstanceId", "${id}" ],
                  %{ endfor }
                    [ "AWS/EC2", "CPUUtilization", "InstanceId", "i-01234567" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "period": 60,
                "stat": "Average"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 3,
            "width": 24,
            "height": 3,
            "properties": {
                "metrics": [
                  %{ for id in aws_instance.ec2_instance.*.id }
                    [ "AWS/EC2", "DiskReadBytes", "InstanceId", "${id}" ],
                  %{ endfor }
                    [ "AWS/EC2", "DiskReadBytes", "InstanceId", "i-01234567" ],
                  %{ for id in aws_instance.ec2_instance.*.id }
                    [ "AWS/EC2", "DiskWriteBytes", "InstanceId", "${id}", { "yAxis": "right" } ],
                  %{ endfor }
                    [ "AWS/EC2", "DiskWriteBytes", "InstanceId", "i-01234567", { "yAxis": "right" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "period": 60,
                "stat": "Average"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 6,
            "width": 24,
            "height": 3,
            "properties": {
                "metrics": [
                  %{ for id in aws_instance.ec2_instance.*.id }
                    [ "AWS/EC2", "NetworkIn", "InstanceId", "${id}" ],
                  %{ endfor }
                    [ "AWS/EC2", "NetworkIn", "InstanceId", "i-01234567" ],
                  %{ for id in aws_instance.ec2_instance.*.id }
                    [ "AWS/EC2", "NetworkOut", "InstanceId", "${id}", { "yAxis": "right" } ],
                  %{ endfor }
                    [ "AWS/EC2", "NetworkOut", "InstanceId", "i-01234567", { "yAxis": "right" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "period": 60,
                "stat": "Average"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 9,
            "width": 24,
            "height": 3,
            "properties": {
                "metrics": [
                  [ "AWS/Route53", "DNSQueries", "HostedZoneId", "${aws_route53_zone.dns_zone.zone_id}" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "period": 60,
                "stat": "Average"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 12,
            "width": 24,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "AWS/SES", "Delivery" ],
                    [ "AWS/SES", "Send" ],
                    [ "AWS/SES", "Reputation.BounceRate", { "yAxis": "right" } ],
                    [ "AWS/SES", "Reputation.ComplaintRate", { "yAxis": "right" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Average",
                "period": 60
            }
        }
    ]
}
EOF
}
