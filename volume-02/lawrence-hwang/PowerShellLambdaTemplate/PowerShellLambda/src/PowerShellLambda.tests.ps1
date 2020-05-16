# Pester Test Place Holder
# Please please please write tests.

Describe 'Sample Pester Test' {
    $TestJson = '{"JsonApiVersion":"1.0"}'

    #Setting the LambdaInput variable to simulate actual Lambda
    $LambdaInput = ConvertFrom-Json -InputObject $TestJson
    $result = (& "$psscriptroot\[[LambdaName]].ps1") | ConvertFrom-Json

    It 'Sample Pester Test for JsonApiVersion value' {
        $result.JsonApiVersion | Should -Be '1.0'
    }
}
