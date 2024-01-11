Write-Host "Waiting for node to sync..."

# RPC endpoint for the defid service
$RPC_ENDPOINT = "http://localhost:8554"

# RPC user and password
$RPC_USER = "defid-user"
$RPC_PASSWORD = "mfemrkn564kjnfg34"

# Base64 encode the user and password
$Bytes = [System.Text.Encoding]::ASCII.GetBytes("${RPC_USER}:${RPC_PASSWORD}")
$Base64 = [System.Convert]::ToBase64String($Bytes)
$AuthHeader = "Basic $Base64"

# Define the headers for the HTTP request, including the authorization header
$Headers = @{
    Authorization = $AuthHeader
    "Content-Type" = "application/json"
}

# Loop until the node is fully synced
while ($true) {
    # Define the body of the JSON-RPC request
    $body = @{
        jsonrpc = "2.0"
        id = "1"
        method = "getblockchaininfo"
        params = @()  # An array of parameters; empty if the method requires no parameters
    }

    # Convert the body to a JSON string
    $json = $body | ConvertTo-Json -Compress

    # Make the JSON-RPC request
    try {
        Write-Host "Making JSON-RPC call to $RPC_ENDPOINT"
        $response = Invoke-RestMethod -Uri $RPC_ENDPOINT -Method Post -Body $json -Headers $Headers

        # Write the whole response object to console for debugging
        $response | Format-List -Force

        $block = $response.result.blocks
        $header = $response.result.headers

        if ($block -eq $header) {
            Write-Host "Node is synced with $block from $header headers"
            break
        }

        Write-Host "Node is syncing... $block out of $header"
    }
    catch {
        Write-Host "Error making JSON-RPC call: $_"
    }

    Start-Sleep -s 10 # check every 10 seconds
}

# Continue with the rest of the script or command to start the backend service
