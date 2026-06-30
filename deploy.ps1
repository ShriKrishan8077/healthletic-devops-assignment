param(
    [string]$Environment,
    [string]$Version,
    [string]$ImageRegistry
)

$LogFile = "deploy.log"

Write-Host "Deployment Started..."
Add-Content $LogFile "Deployment Started..."

if (!$Environment -or !$Version -or !$ImageRegistry) {
    Write-Host "Usage: .\deploy.ps1 <environment> <version> <image_registry>"
    exit 1
}

helm lint ./helm/flask-api

helm upgrade --install healthletic ./helm/flask-api `
  --namespace healthletic `
  --create-namespace `
  --set image.repository=$ImageRegistry `
  --set image.tag=$Version `
  --wait

kubectl rollout status deployment/healthletic -n healthletic

# Smoke Test
Start-Process powershell -WindowStyle Hidden -ArgumentList "kubectl port-forward svc/healthletic 5000:5000 -n healthletic"

Start-Sleep -Seconds 5

try {
    $health = Invoke-RestMethod http://localhost:5000/health
    $db = Invoke-RestMethod http://localhost:5000/db-health

    if ($health.status -eq "healthy" -and $db.database -eq "connected") {
        Write-Host "Smoke Test Passed"
    }
    else {
        throw "Smoke Test Failed"
    }
}
catch {
    Write-Host "Smoke Test Failed. Rolling back..."

    helm rollback healthletic -n healthletic

    exit 1
}

Write-Host "Deployment Successful"
Add-Content $LogFile "Deployment Successful"