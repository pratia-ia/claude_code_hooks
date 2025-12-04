# Hook para registrar la conversación de Claude Code
# Se ejecuta después de cada mensaje del usuario y cada uso de herramienta

# Leer input JSON desde stdin
$inputJson = [Console]::In.ReadToEnd()

# Debug: guardar raw input para diagnóstico
$debugDir = Join-Path $PWD.Path ".claude\logs"
if (-not (Test-Path $debugDir)) {
    New-Item -ItemType Directory -Path $debugDir -Force | Out-Null
}
$debugFile = Join-Path $debugDir "hook-debug.log"
Add-Content -Path $debugFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') RAW INPUT: $inputJson" -Encoding UTF8

try {
    $hookData = $inputJson | ConvertFrom-Json
} catch {
    Add-Content -Path $debugFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') PARSE ERROR: $($_.Exception.Message)" -Encoding UTF8
    exit 0
}

# Extraer campos del JSON
$sessionId = if ($hookData.session_id) { $hookData.session_id } else { "unknown" }
$transcriptPath = if ($hookData.transcript_path) { $hookData.transcript_path } else { "" }
$hookEvent = if ($hookData.hook_event_name) { $hookData.hook_event_name } else { "unknown" }
$cwd = if ($hookData.cwd) { $hookData.cwd } else { $PWD.Path }

# Campos específicos según el tipo de hook
$prompt = if ($hookData.prompt) { $hookData.prompt } else { "" }
$toolName = if ($hookData.tool_name) { $hookData.tool_name } else { "" }
$toolInput = $hookData.tool_input

# Timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$dateStr = Get-Date -Format "yyyyMMdd"

# Configuración de rotación de logs
$maxLogSizeKB = 512  # Tamaño máximo por archivo en KB (512 KB)

# Directorio de logs
$projectDir = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { $cwd }
$logsDir = Join-Path $projectDir ".claude\logs"

# Crear directorio si no existe
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
}

# Archivo de log por día
$logFile = Join-Path $logsDir "conversation-$dateStr.log"

# Función para rotar log si excede el tamaño máximo
function Rotate-LogIfNeeded {
    if (Test-Path $logFile) {
        $fileSizeKB = (Get-Item $logFile).Length / 1KB
        if ($fileSizeKB -ge $maxLogSizeKB) {
            $rotateTimestamp = Get-Date -Format "HHmmss"
            $rotatedPath = Join-Path $logsDir "conversation-$dateStr-$rotateTimestamp.log"
            Move-Item -Path $logFile -Destination $rotatedPath -Force
            return $true
        }
    }
    return $false
}

# Función para escribir en el log
function Write-Log {
    param([string]$Message)
    Add-Content -Path $logFile -Value $Message -Encoding UTF8
}

# Rotar si es necesario antes de escribir
Rotate-LogIfNeeded | Out-Null

# Header si es un nuevo archivo
if (-not (Test-Path $logFile)) {
    Write-Log "=============================================="
    Write-Log "CLAUDE CODE - CONVERSATION LOG"
    Write-Log "Started: $timestamp"
    Write-Log "=============================================="
    Write-Log ""
}

# Registrar según el tipo de evento
switch ($hookEvent) {
    "UserPromptSubmit" {
        Write-Log "[$timestamp] ========== USER MESSAGE =========="
        Write-Log "Session: $sessionId"
        Write-Log "Message:"
        Write-Log $prompt
        Write-Log ""
    }

    "PostToolUse" {
        Write-Log "[$timestamp] ----- TOOL USED: $toolName -----"

        # Registrar input del tool de forma resumida
        switch ($toolName) {
            { $_ -in @("Read", "Write", "Edit") } {
                $filePath = if ($toolInput.file_path) { $toolInput.file_path } elseif ($toolInput.path) { $toolInput.path } else { "unknown" }
                Write-Log "File: $filePath"
            }
            "Bash" {
                $command = if ($toolInput.command) { $toolInput.command.Substring(0, [Math]::Min(200, $toolInput.command.Length)) } else { "" }
                Write-Log "Command: $command..."
            }
            { $_ -in @("Grep", "Glob") } {
                $pattern = if ($toolInput.pattern) { $toolInput.pattern } else { "" }
                Write-Log "Pattern: $pattern"
            }
            "Task" {
                $desc = if ($toolInput.description) { $toolInput.description } else { "" }
                Write-Log "Task: $desc"
            }
            default {
                $inputStr = ($toolInput | ConvertTo-Json -Compress -Depth 2)
                if ($inputStr.Length -gt 300) { $inputStr = $inputStr.Substring(0, 300) + "..." }
                Write-Log "Input: $inputStr"
            }
        }
        Write-Log ""
    }

    "Stop" {
        Write-Log "[$timestamp] ========== ASSISTANT RESPONSE =========="

        # Intentar leer el transcript para obtener la respuesta del asistente
        if ($transcriptPath -and (Test-Path $transcriptPath)) {
            try {
                # El transcript es NDJSON (una línea = un JSON)
                $lines = Get-Content -Path $transcriptPath -Encoding UTF8
                $responseText = ""

                # Recorrer desde el final buscando mensajes del asistente con texto
                for ($i = $lines.Count - 1; $i -ge 0; $i--) {
                    $line = $lines[$i]
                    if (-not $line) { continue }

                    try {
                        $msg = $line | ConvertFrom-Json

                        # Buscar mensajes tipo assistant con contenido de texto
                        if ($msg.type -eq "assistant" -and $msg.message -and $msg.message.content) {
                            foreach ($content in $msg.message.content) {
                                if ($content.type -eq "text" -and $content.text) {
                                    $responseText = $content.text + $responseText
                                }
                            }
                        }

                        # Si encontramos un mensaje de usuario, ya tenemos todo el response
                        if ($msg.type -eq "user" -and $responseText) {
                            break
                        }
                    } catch {
                        # Ignorar líneas que no son JSON válido
                        continue
                    }
                }

                if ($responseText) {
                    # Limitar longitud para evitar logs enormes
                    if ($responseText.Length -gt 2000) {
                        $responseText = $responseText.Substring(0, 2000) + "`n... [truncado]"
                    }
                    Write-Log "Response:"
                    Write-Log $responseText
                } else {
                    Write-Log "[No se encontró texto en la respuesta]"
                }
            } catch {
                Write-Log "[Error leyendo transcript: $($_.Exception.Message)]"
            }
        } else {
            Write-Log "[Transcript no disponible]"
        }
        Write-Log ""
    }

    default {
        Write-Log "[$timestamp] Event: $hookEvent"
        Write-Log ""
    }
}

exit 0
