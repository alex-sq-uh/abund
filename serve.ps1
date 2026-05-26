$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:3000/")
$listener.Start()
Write-Host "Serving on http://localhost:3000/"
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $req = $ctx.Request
  $res = $ctx.Response
  $path = $req.Url.LocalPath.TrimStart('/')
  if ($path -eq '' -or $path -eq '/') { $path = 'index.html' }
  $file = Join-Path (Split-Path $MyInvocation.MyCommand.Path) $path
  if (Test-Path $file) {
    $bytes = [System.IO.File]::ReadAllBytes($file)
    $ext = [System.IO.Path]::GetExtension($file)
    $mime = switch ($ext) { '.html' { 'text/html; charset=utf-8' } '.js' { 'application/javascript' } '.css' { 'text/css' } default { 'application/octet-stream' } }
    $res.ContentType = $mime
    $res.ContentLength64 = $bytes.Length
    $res.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $res.StatusCode = 404
  }
  $res.OutputStream.Close()
}
