<# License>------------------------------------------------------------

 Copyright (c) 2018 Shinnosuke Yakenohara

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>

-----------------------------------------------------------</License #>

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

#変数宣言
$rec = "/r" #Recursive処理指定文字列
$isRec = $FALSE #Recursiveに処理するかどうか

#Recursiveに処理するかどうかをチェック
$isRec = $FALSE
$mxOfArgs = $Args.count
for ($idx = 0 ; $idx -lt $mxOfArgs ; $idx++){
    
    if($Args[$idx] -eq $rec){ #Recursive処理指定文字列の場合
        $isRec = $TRUE
        $Args[$idx] = $null #処理対象から除外
        break
        
    }
}

#処理対象リスト作成
$list = New-Object System.Collections.Generic.List[System.String]

foreach ($arg in $args){
    
    if($arg -ne $null){ #処理対象から除外していなければ
        
        $list.Add($arg)
        
        if ((Test-Path $arg -PathType Container) -And ($isRec)){ #ディレクトリでかつRecursive処理指定の場合
            Get-ChildItem  -Recurse -Force -Path $arg | ForEach-Object {
                $list.Add($_.FullName)
            }
        }
    }
}

if($list.Count -eq 0){
    Write-Host "Argument not specified"
    Read-Host "続行するにはEnterキーを押してください . . ."
    exit #処理終了する
}

#変数宣言
$scs = 0
$err = 0
$excluded = 0

#変換ループ
foreach ($path in $list) {
    
    if (Test-Path $path -PathType Container) { #ディレクトリの場合
        
        if($isRec){ #Recursiveに処理する場合
            Write-Host $path
            $scs++
            
        }else{
            Write-Warning $path
            Write-Warning "ディレクトリです。処理から除外します。"
            $excluded++
        }
        
    }elseif (Test-Path $path -PathType leaf) { #ファイルの場合
        
        $nowExt = [System.IO.Path]::GetExtension($path) #拡張子文字列を取得
        
        $conv = $FALSE #変換するかどうか
        
        #変換対象ファイル拡張子かどうかチェック
        foreach ($extCandidate in $extCandidates) {
            
            if ($extCandidate -eq $nowExt) { #変換対象ファイル拡張子の時
                $conv = $TRUE #変換するを設定
                break
            }
        }
        
        if ($conv) { #変換対象ファイル拡張子の時
            
            try{
                #UTF-8に変換
                &{[IO.File]::WriteAllText($path, [IO.File]::ReadAllText($path, [Text.Encoding]::Default))}
                Write-Host $path
                $scs++
                
            } catch { #変換失敗の場合
                Write-Error $path
                Write-Error $error[0]
                $err++
                
            }
        
        } else { #変換対象ファイル拡張子でない
            Write-Warning $path
            Write-Warning "変換対象外ファイルです。処理から除外します。"
            $excluded++
            
        }
        
    } else { #存在しないパスの場合
        Write-Warning $path
        Write-Warning "存在しないパスです。処理から除外します。"
        $excluded++
    }
}

Write-Host ""
Write-Host "除外数"
Write-Host $excluded
Write-Host "失敗数"
Write-Host $err

#失敗か警告がある場合はpauseする
if (($excluded -gt 0 ) -Or ($err -gt 0 )){
    Write-Host ""
    Read-Host "続行するにはEnterキーを押してください . . ."
    
}
