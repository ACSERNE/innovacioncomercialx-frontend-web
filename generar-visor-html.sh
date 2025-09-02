#!/bin/bash
# Script cockpitizado para generar visor HTML con estado por servicio

timestamp=$(date +"%Y-%m-%d %H:%M:%S")
html="estado-global.html"
log_dir="logs"

# Detectar últimos logs por tipo
estructura_log=$(ls -t $log_dir/estructura-*.log 2>/dev/null | head -1)
build_log=$(ls -t $log_dir/build-*.log 2>/dev/null | head -1)

# Determinar estado por servicio
estado_servicio() {
  grep "✅ $1 construido correctamente" "$build_log" >/dev/null && echo "✅" && return
  grep "❌ Error al construir $1" "$build_log" >/dev/null && echo "❌" && return
  echo "⚠️"
}

backend_estado=$(estado_servicio backend)
web_estado=$(estado_servicio frontend-web)
mobile_estado=$(estado_servicio frontend-mobile)

# Generar HTML
cat <<HTML > "$html"
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Estado Global del Proyecto</title>
  <style>
    body { font-family: sans-serif; background: #f4f4f4; padding: 2em; }
    h1 { color: #333; }
    table { border-collapse: collapse; width: 100%; background: #fff; }
    th, td { padding: 0.8em; border: 1px solid #ccc; text-align: left; }
    .ok { color: green; }
    .fail { color: red; }
    .warn { color: orange; }
  </style>
</head>
<body>
  <h1>📊 Estado Global del Proyecto</h1>
  <p>Generado: $timestamp</p>
  <table>
    <tr><th>Servicio</th><th>Estado</th><th>Log</th></tr>
    <tr><td>Backend</td><td class="${backend_estado//✅/ok}${backend_estado//❌/fail}${backend_estado//⚠️/warn}">$backend_estado</td><td><a href="$build_log">Ver log</a></td></tr>
    <tr><td>Frontend Web</td><td class="${web_estado//✅/ok}${web_estado//❌/fail}${web_estado//⚠️/warn}">$web_estado</td><td><a href="$build_log">Ver log</a></td></tr>
    <tr><td>Frontend Mobile</td><td class="${mobile_estado//✅/ok}${mobile_estado//❌/fail}${mobile_estado//⚠️/warn}">$mobile_estado</td><td><a href="$build_log">Ver log</a></td></tr>
  </table>
  <p><a href="$estructura_log">Log de estructura</a></p>
</body>
</html>
HTML

echo "✅ Visor generado: $html"
