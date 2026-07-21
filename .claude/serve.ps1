# Minimal static file server for local preview (no Node/Python needed)
$root = Split-Path -Parent $PSScriptRoot
$port = if ($env:PORT) { $env:PORT } else { 5173 }
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Serving $root at http://localhost:$port/"

$mime = @{
  '.html'='text/html'; '.css'='text/css'; '.js'='text/javascript'
  '.jpg'='image/jpeg'; '.jpeg'='image/jpeg'; '.png'='image/png'; '.webp'='image/webp'
  '.svg'='image/svg+xml'; '.mp4'='video/mp4'; '.ico'='image/x-icon'
  '.woff2'='font/woff2'; '.json'='application/json'
  '.xml'='application/xml'; '.txt'='text/plain'; '.zip'='application/zip'
}

while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $reqPath = [System.Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath)
  if ($reqPath -eq '/') { $reqPath = '/index.html' }
  $file = Join-Path $root ($reqPath -replace '/', '\')
  try {
    if ((Test-Path $file -PathType Leaf) -and ((Resolve-Path $file).Path.StartsWith($root))) {
      $bytes = [System.IO.File]::ReadAllBytes($file)
      $ext = [System.IO.Path]::GetExtension($file).ToLower()
      $ctx.Response.ContentType = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' }
      $ctx.Response.ContentLength64 = $bytes.Length
      $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $ctx.Response.StatusCode = 404
    }
  } catch {
    try { $ctx.Response.StatusCode = 500 } catch {}
  }
  try { $ctx.Response.OutputStream.Close() } catch {}
}
