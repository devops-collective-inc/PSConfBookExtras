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
    # Parsing the input.
    $FormData = $LambdaInput.body
    $Name = (($FormData -split ('&') | Where-Object { $_ -like 'FName*' }) -split ('='))[-1]
    $Pic = (($FormData -split ('&') | Where-Object { $_ -like 'Pic*' }) -split ('='))[-1]

    $Message = "Hello $Name, here is a picture for you."

    switch ($Pic) {
        Cat {
            $ImgURL = @(
                'https://i.imgflip.com/36s4yf.jpg' #cat
                'https://i.imgflip.com/36s5c6.jpg' #cat
            )
        }
        Dog {
            $ImgURL = @(
                'https://i.imgflip.com/36s48h.jpg' #dog
                'https://i.imgflip.com/36s57s.jpg' #dog
            )
        }
        Surprise {
            $ImgURL = @(
                'https://cdn.bulbagarden.net/upload/thumb/d/d2/459Snover.png/600px-459Snover.png' #snover
                # Image Credit: [bulbapedia](https://bulbapedia.bulbagarden.net/wiki/Snover

                'https://i.imgflip.com/36s541.jpg' #pikachu
            )
        }
    }

    $ImgURL = $ImgURL | Get-Random

    $body = html {
        head {
            Title "PowerShell | Serverless"
        }
        Body {
            hr {
                "Horizontal Line"
            } -Style "border-width: 2px"
            H1 {
                'POWERSHELL &hearts; SERVERLESS!'
            } -Style "text-align:center"
            hr {
                "Horizontal Line"
            } -Style "border-width: 2px"
            h2 {
                $Message
            }
            img -src $ImgURL -alt 'Picture' -width 400
        }
        Footer {
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
