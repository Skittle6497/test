$found = @(
    Get-ChildItem "$env:SystemDrive\Users" -Directory | ForEach-Object {
        $profilePath = $_.FullName

        foreach ($editor in '.cursor', '.vscode') {
            $extensionRoot = Join-Path $profilePath "$editor\extensions"

            if (Test-Path $extensionRoot) {
                Get-ChildItem "$extensionRoot\anthropic.claude-code-*\package.json" -File |
                    ForEach-Object {
                        try {
                            $package = Get-Content $_.FullName -Raw -ErrorAction Stop |
                                ConvertFrom-Json -ErrorAction Stop

                            [PSCustomObject]@{
                                User    = Split-Path $profilePath -Leaf
                                Editor  = $editor
                                Version = $package.version
                                Flagged = $package.version -in @('2.1.312', '2.1.313')
                                Path    = $_.FullName
                            }
                        } catch {
                            Write-Warning "Could not read $($_.FullName): $_"
                        }
                    }
            }
        }
    }
)

if ($found.Count) {
    $found | Format-List
} else {
    'No matching Claude Code extensions found in the default folders checked.'
}
