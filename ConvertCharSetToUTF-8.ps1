#変換対象ファイル拡張子
$extCandidates = @(
	".awk",
	".c",
	".cpp",
	".cxx",
	".cc",
	".cp",
	".c++",
	".h",
	".hpp",
	".hxx",
	".hh",
	".hp",
	".h++",
	".rc",
	".hm",
	".cbl",
	".cpy",
	".pco",
	".cob",
	".html",
	".htm",
	".shtml",
	".plg",
	".java",
	".jav",
	".bat",
	".dpr",
	".pas",
	".cgi",
	".pl",
	".pm",
	".sql",
	".plsql",
	".tex",
	".ltx",
	".sty",
	".bib",
	".log",
	".blg",
	".aux",
	".bbl",
	".toc",
	".lof",
	".lot",
	".idx",
	".ind",
	".glo",
	".bas",
	".frm",
	".cls",
	".ctl",
	".pag",
	".dob",
	".dsr",
	".vb",
	".asm",
	".txt",
	".log",
	".1st",
	".err",
	".ps",
	".rtf",
	".ini",
	".inf",
	".cnf",
	".kwd",
	".col"
)

#変換ループ
$Args | ForEach-Object {
	
	$path = $_
	
	#ファイルの場合
	if (Test-Path $path -PathType leaf) { #ファイルの場合
		
        Write-Host "test"
        Write-Host $path
        
        $nowExt = [System.IO.Path]::GetExtension($path);
        
        Write-Host $nowExt
        
        $conv = $FALSE #変換するかどうか
		
		#変換対象ファイル拡張子かどうかチェック
		$extCandidates | ForEach-Object {
			
			$extCandidate = $_
			
			if ($extCandidate -eq $nowExt[0]) { #変換対象ファイル拡張子の時
				$conv = $TRUE #変換するを設定
				break
			}
			
		}
		
		if ($conv) { #変換対象ファイル拡張子の時
			&{[IO.File]::WriteAllText($path, [IO.File]::ReadAllText($path, [Text.Encoding]::Default))}
		}
	}
}
