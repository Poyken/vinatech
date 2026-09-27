add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int problem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls12,Tls13'

$urls = @(
    @{ Name='BN'; Url='https://42.112.60.211/login' },
    @{ Name='HY'; Url='https://10.0.0.1:4443/login' },
    @{ Name='BG2'; Url='https://14.252.33.178/login' },
    @{ Name='BG1'; Url='https://14.241.37.102/login' }
)

foreach ($u in $urls) {
    try {
        $req = [System.Net.HttpWebRequest]::Create($u.Url)
        $req.Timeout = 10000
        $req.AllowAutoRedirect = $true
        $resp = $req.GetResponse()
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        $html = $reader.ReadToEnd()
        $title = ""
        if ($html -match "<title>(.*?)</title>") {
            $title = $matches[1]
        }
        [PSCustomObject]@{
            Name = $u.Name
            StatusCode = [int]$resp.StatusCode
            Server = $resp.Headers["Server"]
            Title = $title
            ResponseUri = $resp.ResponseUri.ToString()
        }
        $resp.Close()
    } catch {
        [PSCustomObject]@{
            Name = $u.Name
            Error = $_.Exception.Message
        }
    }
}
