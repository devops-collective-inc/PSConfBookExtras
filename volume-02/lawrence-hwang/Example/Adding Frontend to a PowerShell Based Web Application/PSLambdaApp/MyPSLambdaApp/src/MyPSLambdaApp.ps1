#Requires -Modules 'PSHTML'
# Outputting to CloudWatch for troubleshooting. Un-comment this section if you need it.
Write-Host '$LambdaInput'
Write-Host -Object $LambdaInput
$t1 = ConvertTo-Json -Compress $LambdaInput -Depth 5
Write-Verbose -Message $t1 -Verbose
Write-Host 'ENV'
$t2 = Get-ChildItem env:\ | ConvertTo-Json -Depth 1
Write-Verbose -Message $t2 -Verbose

# Add your own code below. Have fun building. :)
try {
    $body = html {
        head {
            Title "PowerShell | Serverless"
        }
        body {
            hr {
                "Horizontal Line"
            } -Style "border-width: 2px"
            h1 {
                'POWERSHELL &hearts; SERVERLESS!'
            } -Style "text-align:center"
            hr {
                "Horizontal Line"
            } -Style "border-width: 2px"
            form {
                "RequestForm"
            } -enctype 'application/x-www-form-urlencoded' -action "/$($LambdaInput.requestContext.stage)" -method 'post' -target '_blank' -Content {
                p {
                    strong { "Hello there, what's your name?" }
                }
                input -type text "FName" -required
                br { }
                br { }
                p {
                    strong { "Select one to show picture." }
                }
                'Cat'
                input -type radio -name "Pic" -value 'Cat' -required
                'Dog'
                input -type radio -name "Pic" -value 'Dog' -required
                'Surprise me!'
                input -type radio -name "Pic" -value 'Surprise' -required
                br { }
                br { }
                input -type submit "Submit" -style "font-family:Charcoal"
            }
        }
        footer {
            Div {
                h5 "P is for PowerShell. $(Get-Date -Format FileDateTimeUniversal)"
            }
        }
    }
    $result = @{
        statusCode = 200
        body       = $body
        headers    = @{
            'Content-Type' = ‘text/html’
        }
    }
    $result
}
catch {
    $MyError = $Error[0]
    Write-Error $MyError
    throw "Error - $MyError"
}
