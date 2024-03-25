param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]
    $msg = ''
)

Add-Type -AssemblyName System.speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$speak.Speak($msg)
