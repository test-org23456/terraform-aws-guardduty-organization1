# terraform-aws-guardduty-organization

## lambda

```mermaid
%%tfmermaid:lambda
%%{init:{"theme":"default","themeVariables":{"lineColor":"#6f7682","textColor":"#6f7682"}}}%%
flowchart LR
classDef r fill:#5c4ee5,stroke:#444,color:#fff
classDef v fill:#eeedfc,stroke:#eeedfc,color:#5c4ee5
classDef ms fill:none,stroke:#dce0e6,stroke-width:2px
classDef vs fill:none,stroke:#dce0e6,stroke-width:4px,stroke-dasharray:10
classDef ps fill:none,stroke:none
classDef cs fill:#f7f8fa,stroke:#dce0e6,stroke-width:2px
subgraph "n0"["CloudWatch Logs"]
n1["aws_cloudwatch_log_group.<br/>guardduty_to_slack"]:::r
end
class n0 cs
subgraph "n2"["IAM (Identity & Access Management)"]
n3["aws_iam_policy.<br/>guardduty_to_slack_kms"]:::r
n4["aws_iam_policy.<br/>guardduty_to_slack_log"]:::r
n5["aws_iam_policy.<br/>guardduty_to_slack_secret"]:::r
n6["aws_iam_role.<br/>guardduty_to_slack"]:::r
n7["aws_iam_role_policy_attachment.<br/>guardduty_to_slack"]:::r
n8["aws_iam_role_policy_attachment.<br/>guardduty_to_slack_kms"]:::r
n9["aws_iam_role_policy_attachment.<br/>guardduty_to_slack_log"]:::r
na["aws_iam_role_policy_attachment.<br/>guardduty_to_slack_secret"]:::r
nb{{"data.<br/>aws_iam_policy_document.<br/>guardduty_to_slack"}}:::r
nc{{"data.<br/>aws_iam_policy_document.<br/>guardduty_to_slack_kms"}}:::r
nd{{"data.<br/>aws_iam_policy_document.<br/>guardduty_to_slack_log"}}:::r
ne{{"data.<br/>aws_iam_policy_document.<br/>guardduty_to_slack_secret"}}:::r
nf{{"data.<br/>aws_iam_policy_document.<br/>key"}}:::r
end
class n2 cs
subgraph "ng"["KMS (Key Management)"]
nh["aws_kms_alias.guardduty"]:::r
ni["aws_kms_key.guardduty"]:::r
end
class ng cs
subgraph "nj"["Lambda"]
nk["aws_lambda_function.<br/>guardduty_to_slack"]:::r
end
class nj cs
subgraph "nl"["Secrets Manager"]
nm["aws_secretsmanager_secret.<br/>guardduty"]:::r
nn["aws_secretsmanager_secret_version.<br/>guardduty"]:::r
end
class nl cs
no{{"data.<br/>archive_file.<br/>guardduty_to_slack"}}:::r
subgraph "np"["STS (Security Token)"]
nq{{"data.<br/>aws_caller_identity.<br/>admin"}}:::r
end
class np cs
subgraph "nr"["Output Values"]
ns(["output.aws_region"]):::v
nt(["output.function"]):::v
nu(["output.secretsmanager_secret"]):::v
end
class nr vs
subgraph "nv"["Input Variables"]
nw(["var.aws_region"]):::v
nx(["var.parameters"]):::v
end
class nv vs
ny(["local.<br/>guardduty_to_slack_policy_arns"]):::v
nz(["local.example_secret"]):::v
n10(["local.function_name"]):::v
ni-->n1
nc-->n3
nd-->n4
ne-->n5
nb-->n6
n6-->n7
ny-->n7
n3-->n8
n6-->n8
n4-->n9
n6-->n9
n5-->na
n6-->na
ni-->nh
nf-->ni
n6-->nk
nm-->nk
no-->nk
ni-->nm
nm-->nn
nz-->nn
ni-->nc
n1-->nd
nm-->ne
nq-->nf
n10-->nf
nw--->ns
nk--->nt
nm--->nu
```

## region

```mermaid
%%tfmermaid:region
%%{init:{"theme":"default","themeVariables":{"lineColor":"#6f7682","textColor":"#6f7682"}}}%%
flowchart LR
classDef r fill:#5c4ee5,stroke:#444,color:#fff
classDef v fill:#eeedfc,stroke:#eeedfc,color:#5c4ee5
classDef ms fill:none,stroke:#dce0e6,stroke-width:2px
classDef vs fill:none,stroke:#dce0e6,stroke-width:4px,stroke-dasharray:10
classDef ps fill:none,stroke:none
classDef cs fill:#f7f8fa,stroke:#dce0e6,stroke-width:2px
subgraph "n0"["EventBridge"]
n1["aws_cloudwatch_event_rule.<br/>guardduty"]:::r
n2["aws_cloudwatch_event_target.<br/>guardduty"]:::r
end
class n0 cs
subgraph "n3"["GuardDuty"]
n4["aws_guardduty_detector.admin"]:::r
n5["aws_guardduty_detector.master"]:::r
n6["aws_guardduty_filter.admin"]:::r
n7["aws_guardduty_ipset.admin"]:::r
n8["aws_guardduty_member.admin"]:::r
n9["aws_guardduty_organization_admin_account.<br/>master"]:::r
na["aws_guardduty_organization_configuration.<br/>admin"]:::r
nb["aws_guardduty_threatintelset.<br/>admin"]:::r
end
class n3 cs
subgraph "nc"["KMS (Key Management)"]
nd["aws_kms_alias.guardduty"]:::r
ne["aws_kms_key.guardduty"]:::r
end
class nc cs
subgraph "nf"["Lambda"]
ng["aws_lambda_permission.<br/>guardduty"]:::r
end
class nf cs
subgraph "nh"["SNS (Simple Notification)"]
ni["aws_sns_topic.guardduty"]:::r
nj["aws_sns_topic_policy.<br/>guardduty"]:::r
nk["aws_sns_topic_subscription.<br/>guardduty"]:::r
end
class nh cs
subgraph "nl"["STS (Security Token)"]
nm{{"data.<br/>aws_caller_identity.<br/>admin"}}:::r
end
class nl cs
subgraph "nn"["IAM (Identity & Access Management)"]
no{{"data.<br/>aws_iam_policy_document.<br/>guardduty"}}:::r
np{{"data.<br/>aws_iam_policy_document.<br/>key"}}:::r
end
class nn cs
subgraph "nq"["Organizations"]
nr{{"data.<br/>aws_organizations_organization.<br/>master"}}:::r
end
class nq cs
subgraph "ns"["Input Variables"]
nt(["var.aws_region"]):::v
nu(["var.parameters"]):::v
end
class ns vs
nv(["local.<br/>finding_publishing_frequency"]):::v
nw(["local.filters"]):::v
nx(["local.s3"]):::v
ny(["local.accounts"]):::v
nz(["local.admin_account_id"]):::v
n10(["local.lambda"]):::v
n1-->n2
ni-->n2
nv-->n4
nv-->n5
n4-->n6
nw-->n6
n4-->n7
nx-->n7
n5-->n8
na-->n8
ny-->n8
n4-->n9
nz-->n9
n9-->na
n4-->nb
nx-->nb
ne-->nd
np-->ne
ni-->ng
nd-->ni
no-->nj
ni-->nk
n10-->nk
ni-->no
nm-->np
nr-->ny
nz-->ny
nm-->nz
nu--->nw
nu--->nv
nu--->n10
nu--->nx
```

## s3

```mermaid
%%tfmermaid:s3
%%{init:{"theme":"default","themeVariables":{"lineColor":"#6f7682","textColor":"#6f7682"}}}%%
flowchart LR
classDef r fill:#5c4ee5,stroke:#444,color:#fff
classDef v fill:#eeedfc,stroke:#eeedfc,color:#5c4ee5
classDef ms fill:none,stroke:#dce0e6,stroke-width:2px
classDef vs fill:none,stroke:#dce0e6,stroke-width:4px,stroke-dasharray:10
classDef ps fill:none,stroke:none
classDef cs fill:#f7f8fa,stroke:#dce0e6,stroke-width:2px
subgraph "n0"["KMS (Key Management)"]
n1["aws_kms_alias.guardduty"]:::r
n2["aws_kms_key.guardduty"]:::r
end
class n0 cs
subgraph "n3"["S3 (Simple Storage)"]
n4["aws_s3_bucket.guardduty"]:::r
n5["aws_s3_bucket_acl.guardduty"]:::r
n6["aws_s3_bucket_policy.<br/>guardduty"]:::r
n7["aws_s3_bucket_public_access_block.<br/>guardduty"]:::r
n8["aws_s3_bucket_server_side_encryption_configuration.<br/>guardduty"]:::r
n9["aws_s3_object.ipset"]:::r
na["aws_s3_object.threatintelset"]:::r
end
class n3 cs
subgraph "nb"["STS (Security Token)"]
nc{{"data.<br/>aws_caller_identity.<br/>admin"}}:::r
end
class nb cs
subgraph "nd"["IAM (Identity & Access Management)"]
ne{{"data.<br/>aws_iam_policy_document.<br/>guardduty"}}:::r
nf{{"data.<br/>aws_iam_policy_document.<br/>key"}}:::r
end
class nd cs
subgraph "ng"["Output Values"]
nh(["output.ipset_location"]):::v
ni(["output.<br/>threatintelset_location"]):::v
end
class ng vs
subgraph "nj"["Input Variables"]
nk(["var.aws_region"]):::v
nl(["var.parameters"]):::v
end
class nj vs
n2-->n1
nf-->n2
n4-->n5
n7-->n6
ne-->n6
n4-->n7
n2-->n8
n4-->n8
n4-->n9
n4-->na
n4-->ne
nc-->ne
nc-->nf
n9--->nh
na--->ni
```

