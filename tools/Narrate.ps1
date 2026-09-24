param(
    [string]$InputFile = '',
    [string]$OutputFile = '',
    [string]$Voice = '',
    [ValidateRange(-10, 10)][int]$Rate = -1,
    [switch]$ListVoices
)

# Run with Windows PowerShell 5.1 (powershell.exe), which includes System.Speech.
# This uses locally installed Windows voices; no API key or cloud service.
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Add-Type -AssemblyName System.Speech
$speaker = New-Object System.Speech.Synthesis.SpeechSynthesizer
try {
    $availableVoices = @($speaker.GetInstalledVoices() | Where-Object Enabled | ForEach-Object { $_.VoiceInfo.Name })
    if ($ListVoices) {
        $availableVoices | ForEach-Object { Write-Output $_ }
        return
    }
    if ($availableVoices.Count -eq 0) { throw 'No Windows speech voices are installed. Add an English speech voice in Windows Settings.' }
    if (-not $Voice) {
        $Voice = $availableVoices | Where-Object { $_ -match 'Zira' } | Select-Object -First 1
        if (-not $Voice) { $Voice = $availableVoices[0] }
    }
    if ($availableVoices -notcontains $Voice) { throw "Voice unavailable: $Voice. Use -ListVoices to see installed voices." }
    if (-not $InputFile) { $InputFile = Join-Path $projectRoot 'docs\history\STORY_EXPLORATIONS.md' }
    if (-not $OutputFile) { $OutputFile = Join-Path $projectRoot 'artifacts\narration\story-explorations.wav' }
    $InputFile = (Resolve-Path -LiteralPath $InputFile).Path
    $OutputFile = [System.IO.Path]::GetFullPath($OutputFile)
    $outputDirectory = Split-Path -Parent $OutputFile
    New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
    $markdown = Get-Content -LiteralPath $InputFile -Raw -Encoding UTF8
    # Preserve the prose while removing visual-only Markdown notation.
    $prose = $markdown -replace '(?m)^#{1,6}\s+', ''
    $prose = $prose -replace '\*\*([^*]+)\*\*', '$1'
    $prose = $prose -replace '\[([^\]]+)\]\([^)]+\)', '$1'
    $prose = $prose -replace '(?m)^[-*]\s+', ''
    $prose = $prose -replace '`', ''
    $paragraphs = $prose -split '\r?\n\s*\r?\n'
    $htmlParagraphs = foreach ($paragraph in $paragraphs) {
        '<p>' + [System.Net.WebUtility]::HtmlEncode(($paragraph -replace '\r?\n', ' ').Trim()) + '</p>'
    }
    $audioName = [System.Net.WebUtility]::HtmlEncode([System.IO.Path]::GetFileName($OutputFile))
    $htmlFile = [System.IO.Path]::ChangeExtension($OutputFile, '.html')
    $html = '<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Frontier Worlds - Story Explorations</title><style>body{margin:0;background:#101a27;color:#e5eef4;font:19px/1.7 system-ui,sans-serif}main{max-width:800px;margin:60px auto;padding:24px}h1{line-height:1.2}p{margin:1.4em 0}audio{width:100%}aside{color:#92cfc0;font-size:15px}</style><main><h1>Frontier Worlds: Story Explorations</h1><audio controls preload="metadata" src="' + $audioName + '"></audio><aside>Local Windows narration. To try another voice, open this page in Microsoft Edge and use Read Aloud and Voice options.</aside><article>' + ($htmlParagraphs -join "`n") + '</article></main></html>'
    Set-Content -LiteralPath $htmlFile -Value $html -Encoding UTF8
    $speaker.SelectVoice($Voice)
    $speaker.Rate = $Rate
    $speaker.Volume = 100
    $speaker.SetOutputToWaveFile($OutputFile)
    Write-Host "Narrating with $Voice (rate $Rate)..."
    $prompt = New-Object System.Speech.Synthesis.PromptBuilder
    foreach ($paragraph in $paragraphs) {
        $text = ($paragraph -replace '\r?\n', ' ').Trim()
        if ($text) {
            $prompt.StartParagraph()
            $prompt.AppendText($text)
            $prompt.EndParagraph()
            $prompt.AppendBreak([TimeSpan]::FromMilliseconds(350))
        }
    }
    $speaker.Speak($prompt)
    $speaker.SetOutputToNull()
    Write-Host "Saved narration: $OutputFile"
    Write-Host "Saved reading page: $htmlFile"
    Write-Host ('Words: ' + ($prose -split '\s+' | Where-Object { $_ }).Count)
} finally {
    $speaker.Dispose()
}
