# Define the required modules
#Requires -Module AWS.Tools.Common,AWS.Tools.CodePipeline,AWS.Tools.CodeCommit,AWS.Tools.S3,AWS.Tools.CloudFormation,AWS.Tools.SimpleNotificationService

# Retrieve the repository name and commit id from the CodePipeline variable
$UserParameters = $LambdaInput.'CodePipeline.job'.data.actionConfiguration.configuration.UserParameters -split ', '
$RepositoryName = $UserParameters[0]
$CommitId = $UserParameters[1]
Write-Host "Repository name is $RepositoryName"
Write-Host "Commit Id is $CommitId"

$JobId = $LambdaInput.'CodePipeline.job'.id
Write-Host "CodePipeline job Id is $JobId"

$SNSTopicName = 'LambdaSNSTopic'
$SNSTopicArn = Get-SNSTopic | Where-Object TopicArn -Like *$SNSTopicName

# Download the artifact from the S3 bucket and extract in the Lambda function
$ArtifactBucket = $LambdaInput.'CodePipeline.job'.data.inputArtifacts.location.s3Location.bucketName
$ArtifactKey = $LambdaInput.'CodePipeline.job'.data.inputArtifacts.location.s3Location.objectKey

Write-Host "Bucket name is $ArtifactBucket"
Write-Host "Key Id is $ArtifactKey"

$ArtifactPath = "/tmp/$ArtifactKey"
$RepoPath = "/tmp/$RepositoryName"
Read-S3Object -BucketName $ArtifactBucket -Key $ArtifactKey -File $ArtifactPath
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($ArtifactPath, $RepoPath)

# Retrieve the latest commited file name from the CodeCommit repository with commited message
$CodeCommitFile = Get-CCCommit -RepositoryName $RepositoryName -CommitId $CommitId -Select Commit.Message
$CodeCommitFile = $CodeCommitFile -replace "`n",""
Write-Host "Parameter file is $CodeCommitFile"

# Retrieve the CloudFormation template body and paramter
$CfnParameter = Get-Content -Path "$RepoPath/$CodeCommitFile" | ConvertFrom-Json
$CfnTemplate = Get-Content -Path "$RepoPath/sample-ec2-template.yaml" -Raw
$StackName = ($CfnParameter | Where-Object ParameterKey -EQ InstanceName).ParameterValue

# CloudFormation creation process
try {
    
    # Creating a new CloudFormation stack
    Write-Host "Stack name is $StackName"
    New-CFNStack -StackName $StackName -TemplateBody $CfnTemplate -Parameter $CfnParameter
    Wait-CFNStack -StackName $StackName -Status CREATE_COMPLETE,CREATE_FAILED,ROLLBACK_COMPLETE,ROLLBACK_FAILED

    # Retrieve the outputs from the new stack
    $StackDetail = Get-CFNStack -StackName $StackName

    # Send a notification the status of stack creation
    $Subject = "$StackName is created successful."
    $Message = $StackDetail.Outputs | ConvertTo-Json -Compress
    Publish-SNSMessage -TargetArn $SNSTopicArn.TopicArn -Subject $Subject -Message $Message -ErrorAction SilentlyContinue

    # Send the outputs to CloudWatch log
    Write-Host $Message

    # Respond CodePipeline as Success if the stack creation is successful.
    Write-CPJobSuccessResult -JobId $JobId
}
catch {
    
    # Send a notification the status of stack creation
    $Subject = "$StackName is created unsuccessful."
    $Message = $PSItem.Exception.Message
    Publish-SNSMessage -TargetArn $SNSTopicArn.TopicArn -Subject $Subject -Message $Message -ErrorAction SilentlyContinue

    # Send the outputs to CloudWatch log
    Write-Host $Message

    # Respond CodePipeline as Fail if the stack creation is unsuccessful.
    Write-CPJobFailureResult -JobId $JobId -FailureDetails_Message $Message -FailureDetails_Type JobFailed
}
