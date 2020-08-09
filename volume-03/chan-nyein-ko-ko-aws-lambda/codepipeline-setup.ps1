# Create a new S3 bucket to store the artifact
$BucketName = "<bucket-name>"
New-S3Bucket -BucketName $BucketName

# Policy document for CodePipeline to execute AWS resources
$PolicyDocument = '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEqualsIfExists": {
                    "iam:PassedToService": [
                        "cloudformation.amazonaws.com",
                        "ec2.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "sns:*",
                "cloudformation:SetStackPolicy",
                "codecommit:UploadArchive",
                "lambda:ListFunctions",
                "lambda:InvokeFunction",
                "s3:*",
                "cloudformation:*",
                "cloudformation:CreateChangeSet",
                "codecommit:CancelUploadArchive",
                "cloudformation:DeleteChangeSet",
                "cloudformation:DescribeStacks",
                "codecommit:GetCommit",
                "codecommit:GetUploadArchiveStatus",
                "cloudwatch:*",
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "codecommit:GetBranch",
                "ec2:*",
                "cloudformation:UpdateStack",
                "cloudformation:DescribeChangeSet",
                "cloudformation:ExecuteChangeSet",
                "cloudformation:ValidateTemplate"
            ],
            "Resource": "*"
        }
    ]
}'

# Create a policy name 'lambda-ec2-codepipeline-policy'
$PolicyName = 'lambda-ec2-codepipeline-policy'
New-IAMPolicy -PolicyName $PolicyName -PolicyDocument $PolicyDocument

# Retrieve the ARN of newly create policy 'lambda-ec2-codepipeline-policy'
$LambdaEc2CPPolicy = Get-IAMPolicyList | Where-Object PolicyName -EQ 'lambda-ec2-codepipeline-policy'

# Assumed Role policy document for CodePipeline service role
$ServiceDocument = '{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "codepipeline.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}'

# Create a role named 'lambda-ec2-codepipeline-role'
$RoleName = 'lambda-ec2-codepipeline-role'
$Parameters = ${
    RoleName = $RoleName
    AssumeRolePolicyDocument = $ServiceDocument
    Path = '/service-role/'
}
New-IAMRole @Parameters
Register-IAMRolePolicy -RoleName $RoleName -PolicyArn $LambdaEc2CPPolicy.Arn
$CodePipelineRole = Get-IAMRole -RoleName $RoleName

# Create a source structure
$SourceAction = New-Object Amazon.CodePipeline.Model.ActionDeclaration

$SourceAction.Name = "CodeCommit_Repo"
$SourceAction.ActionTypeId = @{
    "Category" = "Source";
    "Owner" = "AWS";
    "Provider" = "CodeCommit";
    "Version" = 1
}
$SourceAction.Configuration.Add("RepositoryName", "aws-cloudformation-repo")
$SourceAction.Configuration.Add("BranchName", "master")
$SourceAction.Namespace = "SourceVariables"

$SourceActionArtifact = New-Object Amazon.CodePipeline.Model.OutputArtifact
$SourceActionArtifact.Name = "SourceArtifact"
$SourceAction.OutputArtifacts.Add($SourceActionArtifact)

# Create a deploy structure
$DeployAction = New-Object Amazon.CodePipeline.Model.ActionDeclaration

$DeployAction.Name = "Lambda_Function"
$DeployAction.ActionTypeId = @{
    "Category" = "Invoke";
    "Owner" = "AWS";
    "Provider" = "Lambda";
    "Version" = 1
}
$InputVariables = '#{SourceVariables.RepositoryName}, #{SourceVariables.CommitId}'
$DeployAction.Configuration.Add("FunctionName", "ec2-cloudformation-function")
$DeployAction.Configuration.Add("UserParameters", "$InputVariables")

$DeployActionInputArtifact = New-Object Amazon.CodePipeline.Model.InputArtifact
$DeployActionInputArtifact.Name = "SourceArtifact"
$DeployAction.InputArtifacts.Add($DeployActionInputArtifact)

# Create a pipeline structure
$CodePipeline = New-Object Amazon.CodePipeline.Model.PipelineDeclaration

$SourceStage = New-Object Amazon.CodePipeline.Model.StageDeclaration
$DeployStage = New-Object Amazon.CodePipeline.Model.StageDeclaration

$SourceStage.Name = "Source"
$DeployStage.Name = "Deploy"

$SourceStage.Actions.Add($SourceAction)
$DeployStage.Actions.Add($DeployAction)

$CodePipeline.ArtifactStore = @{"Location" = "$BucketName"; "Type" = "S3"}
$CodePipeline.Name = "lambda-ec2-pipeline"
$CodePipeline.RoleArn = $CodePipelineRole.Arn
$CodePipeline.Stages.Add($SourceStage)
$CodePipeline.Stages.Add($DeployStage)
$CodePipeline.Version = 1

# Create a CodePipeline
New-CPPipeline -Pipeline $CodePipeline
